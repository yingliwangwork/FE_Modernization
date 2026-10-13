#!/usr/bin/env python3
"""Resolve template paths and hashes; print a manifest without writing outputs.

- Config paths resolve relative to the config directory (otherwise cwd).
- Only requested-phase override paths are resolved; unknown keys/roles fail.
- Custom stacks require a custom entry and never fall back to vanilla bundles.
- Execution, applicability and authorization belong to guides/workflow.md.
- Configuration and instruction resolution belong to guides/customization.md.
"""
import argparse
import hashlib
import json
from pathlib import Path
import sys

ROLES = {
    "api-spec": "spec/api-spec.md",
    "ui-spec": "spec/ui-spec.md",
    "prd": "spec/prd.md",
    "bdd": "spec/bdd.feature",
    "prototype": "prototype/prototype.html",
    "prototype-css": "prototype/prototype.css",
    "prototype-js": "prototype/prototype.js",
}
PHASE_ROLES = {"spec": tuple(ROLES)[:4], "prototype": tuple(ROLES)[4:]}
DEFAULT_STACK = "html-css-javascript"


def regular_file(path):
    if not path.is_file():
        raise ValueError("指定檔案不存在或不是檔案: " + str(path))
    return path.resolve()


def file_record(path):
    return {"path": str(path), "sha256": hashlib.sha256(path.read_bytes()).hexdigest()}


def resolve_templates(config_path=None, skill_root=None, phase="spec"):
    if phase not in PHASE_ROLES:
        raise ValueError("未知 phase；只接受 spec、prototype")
    skill_root = Path(skill_root or Path(__file__).resolve().parents[1])
    if not skill_root.is_dir():
        raise ValueError("指定 skill_root 不存在或不是目錄: " + str(skill_root))
    config = {}
    base = Path.cwd()
    config_file = None
    if config_path is not None:
        config_file = regular_file(Path(config_path))
        base = config_file.parent
        config = json.loads(config_file.read_text(encoding="utf-8"))
    if not isinstance(config, dict):
        raise ValueError("設定必須是 JSON object")
    if "style_profile" in config:
        raise ValueError("style_profile 已移除：請遷移 DESIGN/tokens 到 ui-spec 的 STYLE 映射；"
                         "prototype 技術棧改用 prototype_stack 與單元 instruction 文件")
    unknown = set(config) - {"template_root", "overrides", "references", "prototype_stack", "output_root"}
    if unknown:
        raise ValueError("未知設定欄位: " + ", ".join(sorted(unknown)))

    def location(value, field):
        if not isinstance(value, str) or not value.strip():
            raise ValueError(field + " 路徑必須是非空字串")
        return (base / value).resolve()

    custom_root = location(config["template_root"], "template_root") if "template_root" in config else None
    if custom_root is not None and not custom_root.is_dir():
        raise ValueError("指定 template_root 不存在或不是目錄: " + str(custom_root))
    overrides = config.get("overrides", {})
    if not isinstance(overrides, dict):
        raise ValueError("overrides 必須是以已定義角色為 key 的 object")
    unknown_roles = set(overrides) - set(ROLES)
    if unknown_roles:
        raise ValueError("未知 overrides 角色: " + ", ".join(sorted(unknown_roles)))
    stack = config.get("prototype_stack", DEFAULT_STACK)
    if not isinstance(stack, str) or not stack.strip():
        raise ValueError("prototype_stack 必須是非空字串")
    custom_stack = phase == "prototype" and stack != DEFAULT_STACK
    limits = [
        "Selection resolves paths and hashes only; see guides/workflow.md for execution and authorization.",
        "Spec phase lists four candidate roles, not completed documents or applicability decisions.",
        "Prototype gates and delivery checks belong to guides/acceptance.md; this CLI does not verify them.",
        "The agent resolves instruction files under guides/customization.md; this CLI does not load them.",
        "Manifest paths are proposed locations; no output files or directories are created.",
    ]
    selected = {}
    for role in PHASE_ROLES[phase]:
        relative = ROLES[role]
        candidate = custom_root / relative if custom_root is not None else None
        if role in overrides:
            path = regular_file(location(overrides[role], "overrides." + role))
            origin = "explicit-override"
        elif candidate is not None and (candidate.exists() or candidate.is_symlink()):
            path = regular_file(candidate)
            origin = "project-template-root"
        elif custom_stack:
            if role == "prototype":
                raise ValueError("非預設 prototype_stack " + repr(stack) +
                                 " 需要 overrides.prototype 或 template_root 中的 "
                                 + ROLES["prototype"] + "；禁止回退 vanilla 內建範本")
            continue
        else:
            path = regular_file(skill_root / "templates" / relative)
            origin = "builtin"
            if custom_root is not None:
                limits.append("Custom template_root missing " + relative +
                              "; " + role + " fell back to builtin.")
        selected[role] = {**file_record(path), "origin": origin}
    if custom_stack:
        limits.append("Custom stack requires a custom prototype entry; only supplied prototype-css/"
                      "prototype-js bundle slots are selected, with no vanilla fallbacks. "
                      "Override paths may use any extension; role names are stable manifest slots.")
    references = config.get("references", {})
    if not isinstance(references, dict) or set(references) - {"api", "ui", "domain"}:
        raise ValueError("references 只接受 api、ui、domain 分類")
    resolved_references = {}
    for kind, paths in references.items():
        if not isinstance(paths, list):
            raise ValueError("references 各分類必須是路徑陣列")
        resolved_references[kind] = []
        for raw in paths:
            path = regular_file(location(raw, "references." + kind))
            resolved_references[kind].append(file_record(path))
    output_root = location(config.get("output_root", "artifacts"), "output_root")
    if output_root.exists() and not output_root.is_dir():
        raise ValueError("指定 output_root 不是目錄: " + str(output_root))
    scope_root = output_root / "<scope>"
    result = {"schema_version": 2, "phase": phase,
            "config": str(config_file) if config_file else None,
            "config_sha256": hashlib.sha256(config_file.read_bytes()).hexdigest() if config_file else None,
            "output_root": str(output_root),
            "output_layout": {
                "scope_root": str(scope_root),
                "history": {kind: str(scope_root / "history" / kind)
                            for kind in ("planning", "draft", "review", "evidence")},
                "deliverables": {kind: str(scope_root / "deliverables" / kind)
                                 for kind in ("spec", "prd", "bdd", "prototype")},
            },
            "templates": selected, "references": resolved_references,
            "limits": limits}
    if phase == "prototype":
        result["prototype_stack"] = stack
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--config")
    parser.add_argument("--phase", choices=tuple(PHASE_ROLES), default="spec")
    args = parser.parse_args()
    try:
        print(json.dumps(resolve_templates(args.config, phase=args.phase), ensure_ascii=False, indent=2))
    except (ValueError, OSError) as error:
        print(str(error), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
