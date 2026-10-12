#!/usr/bin/env python3
"""Prepare immutable-input sandboxes and inspect actual skill-generated packages.

The LLM trial runs separately with the copied skill. This script never generates
specifications or substitutes structural checks for source-based review.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
from html.parser import HTMLParser
from urllib.parse import unquote, urlsplit

REPO = Path(__file__).resolve().parents[1]


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def snapshot(source, destination, category, records):
    if source.is_symlink() or not source.is_file():
        raise ValueError("Snapshot source must be a regular file: " + str(source))
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(source, destination)
    records.append({"path": str(destination), "origin": str(source),
                    "category": category, "sha256": digest(source)})


def prepare(args):
    if not re.fullmatch(r"[a-z0-9][a-z0-9-]*", args.run):
        raise ValueError("Run ID must use lowercase letters, digits and hyphens")
    target = REPO / "sandbox" / "legacy-to-spec" / args.run / args.case
    if target.exists():
        raise ValueError("Run directory already exists; use a new run ID")
    backend = Path(args.backend_root).resolve() if args.backend_root else None
    if args.case == "afy10400" and not backend:
        raise ValueError("afy10400 requires --backend-root")
    records = []
    try:
        target.mkdir(parents=True)
        skill = REPO / "skills" / "legacy-to-spec"
        for source in sorted(skill.rglob("*")):
            if source.is_file():
                snapshot(source, target / "skill" / source.relative_to(skill), "skill", records)
        if args.case == "coupled":
            fixture = REPO / "tests" / "legacy-to-spec" / "fixtures" / "coupled"
            for source in sorted(fixture.rglob("*")):
                if source.is_file():
                    snapshot(source, target / "inputs" / source.relative_to(fixture), "source", records)
            root = "inputs/frontend/Case.jsp"
            contract = "inputs/backend/api-contract.md"
            scope = "fixture-case"
        else:
            root = "inputs/frontend/sourceCode/AF/AFY10400.jsp"
            contract = "inputs/backend/docs/OPENAPI.md"
            scope = "AF-AFY10400"
            files = ["AF/AFY10400.jsp", "CM/header.jsp", "CM/msgDisplayer.jsp",
                     "CM/css/cm.css", "CM/js/ajax/prototype.js", "CM/js/ajax/CSRUtil.js",
                     "CM/js/ui/PageUI.js", "CM/js/HotKey.js", "CM/js/Validator.js",
                     "CM/js/RPTUtil.js", "CM/js/calendar.js", "CM/js/date.js"]
            for name in files:
                snapshot(REPO / "sourceCode" / name,
                         target / "inputs/frontend/sourceCode" / name, "source", records)
            for name in ["docs/OPENAPI.md", "docs/specs/AFY1_0400/AFY1_0400_doPrompt.md",
                         "docs/specs/AFY1_0400/AFY1_0400_doExport.md",
                         "docs/specs/AFY1_0400/AFY1_0400_doDownload.md"]:
                snapshot(backend / name, target / "inputs/backend" / name, "source", records)
        for record in records:
            record["path"] = str(Path(record["path"]).relative_to(target))
        policy = getattr(args, "dependency_policy", "ask")
        manifest = {"schema_version": 2, "case": args.case, "run": args.run, "scope_id": scope,
                    "root_entry": root, "backend_contract": contract,
                    "backend_root": "inputs/backend", "dependency_policy": policy, "files": records}
        (target / "manifest.json").write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n")
        prompt = (
            "Use the skill at skill/SKILL.md to renovate exactly the root JSP " + root + ".\n"
            "Work only inside this case directory. Read manifest.json for inputs and scope.\n"
            "The selected backend baseline is " + contract + "; use only provided input snapshots.\n"
            "Produce the applicable specification, HTML prototypes, API consumption spec, backend handoff, "
            "and separate tracking under artifacts/. Do not modify skill/, inputs/, or manifest.json.\n"
            "Missing dependencies remain unknown. Do not query or call external systems.\n"
            "Create plan before dependency analysis. Existing dependency contracts may be under inputs/specs/.\n"
            + ({"ask": "No dependency expansion or deferral decision is pre-authorized. Report concrete choices and continue independent work only.\n",
                "defer": "Sandbox-only simulated user decision: reuse suitable existing contracts; defer every dependency lacking a suitable contract. This does not authorize formal project deferral. Record affected positions and follow-up tasks.\n",
                "convert-available": "Sandbox-only simulated user decision: reuse suitable contracts; first convert necessary available dependencies; defer unavailable dependencies with TODOs. This does not authorize formal scope expansion.\n"}[policy]) +
            "Carry out the skill's applicable checks; report actual limits and output paths.\n"
        )
        (target / "task.txt").write_text(prompt)
        print(target)
    except Exception:
        # No prior run exists at this path; remove only this invocation's partial output.
        if target.exists():
            shutil.rmtree(target)
        raise


class Prototype(HTMLParser):
    def __init__(self):
        super().__init__()
        self.ids = []
        self.bindings = []
        self.links = []
        self.scripts = []
        self.script = None
        self.product_root = False
        self.roots = []

    def handle_starttag(self, tag, attributes):
        attrs = dict(attributes)
        if attrs.get("id"):
            self.ids.append(attrs["id"])
        if all(attrs.get(key) for key in ("data-scope-id", "data-screen-id", "data-state-id")):
            self.product_root = True
            self.roots.append({key: attrs[key] for key in ("data-scope-id", "data-screen-id", "data-state-id")})
        for name in ("data-ui-id", "data-flow-id", "data-component-id"):
            if attrs.get(name):
                self.bindings.append(attrs[name])
        for name in ("src", "href", "action"):
            if attrs.get(name):
                self.links.append(attrs[name])
        if tag == "script" and not attrs.get("src"):
            self.script = ""

    def handle_data(self, data):
        if self.script is not None:
            self.script += data

    def handle_endtag(self, tag):
        if tag == "script" and self.script is not None:
            self.scripts.append(self.script)
            self.script = None


def anchors(content):
    result = set(re.findall(r'<(?:a|span)\b[^>]*\bid=["\']([^"\']+)', content))
    used = {}
    for heading in re.findall(r"^#{1,6}\s+(.+?)\s*#*\s*$", content, re.M):
        # CommonMark/GitHub heading IDs, including repeated heading suffixes.
        plain = re.sub(r"<[^>]+>", "", heading).lower()
        plain = re.sub(r"[^\w\- ]", "", plain, flags=re.UNICODE).replace(" ", "-")
        count = used.get(plain, 0)
        used[plain] = count + 1
        result.add(plain + ("-" + str(count) if count else ""))
    return result


def check(args):
    case = Path(args.case_dir).resolve()
    allowed = (REPO / "sandbox" / "legacy-to-spec").resolve()
    if allowed not in case.parents:
        raise ValueError("Case directory must be inside sandbox/legacy-to-spec")
    manifest = json.loads((case / "manifest.json").read_text())
    findings = []
    metrics = {"snapshots": 0, "markdown_files": 0, "html_files": 0, "links": 0}

    def fail(code, detail):
        findings.append({"code": code, "detail": detail})

    for record in manifest["files"]:
        file = case / record["path"]
        if not file.is_file() or digest(file) != record["sha256"]:
            fail("SNAPSHOT_CHANGED", record["path"])
        origin = Path(record["origin"])
        if record["category"] == "source" and (not origin.is_file() or digest(origin) != record["sha256"]):
            fail("ORIGINAL_CHANGED", str(origin))
        metrics["snapshots"] += 1
    scope = manifest["scope_id"]
    artifacts = case / "artifacts"
    required = [f"design/{scope}/specification.md", f"renovation/{scope}/tracking.md",
                f"integration/{scope}/api-spec.md"]
    if manifest["case"] == "coupled":
        required.append(f"integration/{scope}/backend-handoff.md")
    if manifest.get("schema_version", 1) >= 2:
        required.append(f"renovation/{scope}/plan.md")
    for name in required:
        if not (artifacts / name).is_file():
            fail("MISSING_DELIVERABLE", name)
    prototypes = sorted((artifacts / "design" / scope / "prototypes").glob("*.html"))
    if not prototypes:
        fail("MISSING_PROTOTYPE", scope)
    spec_path = artifacts / f"design/{scope}/specification.md"
    specification = spec_path.read_text() if spec_path.exists() else ""

    def inspect_link(source, raw):
        if raw.startswith(("https:", "http:")):
            fail("EXTERNAL_LINK", str(source.relative_to(case)) + ": " + raw)
            return
        if raw.startswith(("mailto:", "javascript:", "data:")):
            fail("UNSUPPORTED_LINK", str(source.relative_to(case)) + ": " + raw)
            return
        parsed = urlsplit(raw)
        if parsed.scheme and parsed.scheme != "file":
            fail("UNSUPPORTED_LINK", raw)
            return
        location = unquote(parsed.path)
        target = (source.parent / location).resolve() if location else source
        if case != target and case not in target.parents:
            fail("LINK_ESCAPES_CASE", str(source.relative_to(case)) + ": " + raw)
            return
        if not target.is_file():
            fail("BROKEN_LINK", str(source.relative_to(case)) + ": " + raw)
            return
        if parsed.fragment and target.suffix == ".md" and unquote(parsed.fragment) not in anchors(target.read_text()):
            fail("BROKEN_ANCHOR", str(source.relative_to(case)) + ": " + raw)
        metrics["links"] += 1

    for file in sorted(artifacts.rglob("*")):
        if not file.is_file() or file.suffix not in (".md", ".html", ".css", ".json"):
            continue
        content = file.read_text()
        if re.search(r"\{\{[^}]*\}\}", content):
            fail("UNFILLED_TEMPLATE", str(file.relative_to(case)))
        if file.suffix == ".md":
            metrics["markdown_files"] += 1
            for link in re.findall(r"\[[^\]]*\]\(([^)]+)\)", content):
                inspect_link(file, link)
        elif file.suffix == ".html":
            metrics["html_files"] += 1
            relative = file.relative_to(artifacts)
            owner_scope = relative.parts[1] if len(relative.parts) >= 4 and relative.parts[0] == "design" else scope
            owner_path = artifacts / "design" / owner_scope / "specification.md"
            owner_specification = owner_path.read_text() if owner_path.is_file() else ""
            if not owner_path.is_file():
                fail("MISSING_OWNER_SPECIFICATION", str(owner_path.relative_to(case)))
            if owner_scope != scope:
                if manifest.get("dependency_policy") != "convert-available":
                    fail("UNAUTHORIZED_DEPENDENCY_SCOPE", owner_scope)
                for name in ("plan.md", "tracking.md"):
                    if not (artifacts / "renovation" / owner_scope / name).is_file():
                        fail("MISSING_DELIVERABLE", f"renovation/{owner_scope}/{name}")
            document = Prototype()
            document.feed(content)
            if len(document.ids) != len(set(document.ids)):
                fail("DUPLICATE_HTML_ID", str(file.relative_to(case)))
            if not document.product_root:
                fail("MISSING_PRODUCT_BINDING", str(file.relative_to(case)))
            for root in document.roots:
                if root["data-scope-id"] != owner_scope:
                    fail("WRONG_PROTOTYPE_SCOPE", root["data-scope-id"])
                for key in ("data-screen-id", "data-state-id"):
                    if root[key] not in owner_specification:
                        fail("UNMAPPED_PROTOTYPE_ID", root[key])
            for binding in document.bindings:
                if binding not in owner_specification:
                    fail("UNMAPPED_PROTOTYPE_ID", binding)
            for link in document.links:
                inspect_link(file, link)
            for script in document.scripts:
                with tempfile.NamedTemporaryFile(suffix=".js", mode="w", dir="/private/tmp") as temp:
                    temp.write(script)
                    temp.flush()
                    result = subprocess.run(["node", "--check", temp.name], capture_output=True, text=True)
                if result.returncode:
                    fail("INVALID_JAVASCRIPT", str(file.relative_to(case)) + ": " + result.stderr)
    report = {"case": manifest["case"], "run": manifest["run"],
              "kind": "structural-and-input-integrity-check",
              "status": "PASS" if not findings else "FAIL", "metrics": metrics,
              "findings": findings,
              "artifact_sha256": {str(file.relative_to(case)): digest(file)
                                  for file in sorted(artifacts.rglob("*")) if file.is_file()},
              "limits": ["Does not establish semantic source coverage, visual fidelity, or integration with a backend.",
                         "Source-based independent review and browser checks are separate required evidence."]}
    reports = case / "reports"
    reports.mkdir(exist_ok=True)
    (reports / "structure.json").write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n")
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return 0 if not findings else 1


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)
    prep = sub.add_parser("prepare")
    prep.add_argument("--case", choices=["coupled", "afy10400"], required=True)
    prep.add_argument("--run", required=True)
    prep.add_argument("--backend-root")
    prep.add_argument("--dependency-policy", choices=["ask", "defer", "convert-available"], default="ask",
                      help="Explicit sandbox simulated decision; never grants formal conversion authorization")
    inspect = sub.add_parser("check")
    inspect.add_argument("--case-dir", required=True)
    args = parser.parse_args()
    try:
        if args.command == "prepare":
            prepare(args)
        else:
            return check(args)
    except (ValueError, OSError) as error:
        print(str(error), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
