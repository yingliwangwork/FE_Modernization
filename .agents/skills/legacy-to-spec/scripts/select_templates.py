#!/usr/bin/env python3
"""Resolve reusable templates without generating or approving system contracts."""
import argparse
import hashlib
import json
from pathlib import Path
import sys

ROLES = {
    "specification": "design/specification.md",
    "prototype": "design/prototype.html",
    "component-design": "design/DESIGN.md",
    "component-css": "design/component.css",
    "tokens": "design/tokens.json",
    "api-spec": "integration/api-spec.md",
    "backend-handoff": "integration/backend-handoff.md",
    "plan": "renovation/plan.md",
    "tracking": "renovation/tracking.md",
}


def regular_file(path):
    if not path.is_file():
        raise ValueError("指定檔案不存在或不是檔案: " + str(path))
    return path.resolve()


def resolve_templates(config_path=None, skill_root=None):
    skill_root = Path(skill_root or Path(__file__).resolve().parents[1])
    config = {}
    base = Path.cwd()
    config_file = None
    if config_path:
        config_file = regular_file(Path(config_path))
        base = config_file.parent
        config = json.loads(config_file.read_text())
    if not isinstance(config, dict):
        raise ValueError("設定必須是 JSON object")
    unknown = set(config) - {"template_root", "overrides", "references", "style_profile", "output_root"}
    if unknown:
        raise ValueError("未知設定欄位: " + ", ".join(sorted(unknown)))

    def location(value):
        if not isinstance(value, str) or not value.strip():
            raise ValueError("路徑必須是非空字串")
        return (base / value).resolve()

    custom_root = location(config["template_root"]) if "template_root" in config else None
    if custom_root and not custom_root.is_dir():
        raise ValueError("指定 template_root 不存在或不是目錄: " + str(custom_root))
    overrides = config.get("overrides", {})
    if not isinstance(overrides, dict) or set(overrides) - set(ROLES):
        raise ValueError("overrides 必須以已定義角色為 key")
    profile = config.get("style_profile", "design-md")
    if profile not in ("design-md", "design-md+dtcg"):
        raise ValueError("未知 style_profile: " + str(profile))
    selected = {}
    for role, relative in ROLES.items():
        if role in overrides:
            path = regular_file(location(overrides[role]))
            origin = "explicit-override"
        elif custom_root and (custom_root / relative).exists():
            path = regular_file(custom_root / relative)
            origin = "project-template-root"
        else:
            path = regular_file(skill_root / "templates" / relative)
            origin = "builtin"
        selected[role] = {"path": str(path), "selected_by": origin,
                          "sha256": hashlib.sha256(path.read_bytes()).hexdigest()}
    references = config.get("references", {})
    if not isinstance(references, dict) or set(references) - {"api", "ui", "domain"}:
        raise ValueError("references 只接受 api、ui、domain 分類")
    resolved_references = {}
    for kind, paths in references.items():
        if not isinstance(paths, list):
            raise ValueError("references 各分類必須是路徑陣列")
        resolved_references[kind] = []
        for raw in paths:
            path = regular_file(location(raw))
            resolved_references[kind].append({"path": str(path), "sha256": hashlib.sha256(path.read_bytes()).hexdigest()})
    return {"schema_version": 1, "config": str(config_file) if config_file else None,
            "config_sha256": hashlib.sha256(config_file.read_bytes()).hexdigest() if config_file else None,
            "style_profile": profile, "output_root": str(location(config.get("output_root", "artifacts"))),
            "templates": selected, "references": resolved_references,
            "limits": ["Selection does not validate template completeness or authorize design changes.",
                       "Only applicable template roles should be used for a scope."]}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--config")
    args = parser.parse_args()
    try:
        print(json.dumps(resolve_templates(args.config), ensure_ascii=False, indent=2))
    except (ValueError, OSError) as error:
        print(str(error), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
