#!/usr/bin/env python3
"""Check DESIGN.md token group shapes; not a full official format validator.

Requires PyYAML in the current Python environment. No files are modified.
"""
import argparse
import json
from pathlib import Path
import re
import sys


def check(path):
    try:
        import yaml
    except ImportError as error:
        raise ValueError("此檢查需現有 Python 環境提供 PyYAML；未執行，不自動安裝") from error
    content = Path(path).read_text()
    frontmatter = re.match(r"\A---\r?\n(.*?)\r?\n---(?:\r?\n|\Z)", content, re.S)
    findings = []
    if not frontmatter:
        return ["本專案 profile 要求 YAML frontmatter，未找到"]
    try:
        data = yaml.safe_load(frontmatter.group(1))
    except yaml.YAMLError as error:
        return ["YAML 無法解析: " + str(error)]
    if not isinstance(data, dict):
        return ["frontmatter 必須是 mapping"]
    if not isinstance(data.get("name"), str) or not data["name"].strip():
        findings.append("name 必須是非空字串")
    for group in ("colors", "typography", "spacing", "rounded", "components"):
        if group not in data:
            continue
        if not isinstance(data[group], dict):
            findings.append(group + " 必須是 token mapping")
            continue
        for name, value in data[group].items():
            location = group + "." + str(name)
            if group in ("typography", "components") and not isinstance(value, dict):
                findings.append(location + " 必須是物件，不能直接放 CSS 宣告字串")
            if group == "colors" and not isinstance(value, str):
                findings.append(location + " 必須是 CSS color 字串")
            if group == "typography" and isinstance(value, dict):
                allowed = {"fontFamily", "fontSize", "fontWeight", "lineHeight", "letterSpacing", "fontFeature", "fontVariation"}
                for key in value:
                    if key not in allowed:
                        findings.append(location + "." + str(key) + " 不是本 alpha profile 的 typography 欄位")
                if "fontFamily" in value and not isinstance(value["fontFamily"], str):
                    findings.append(location + ".fontFamily 必須是字串")
    return findings


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("files", nargs="+")
    args = parser.parse_args()
    try:
        results = [{"file": str(Path(path)), "findings": check(path)} for path in args.files]
    except (OSError, ValueError) as error:
        print(str(error), file=sys.stderr)
        return 1
    failed = any(row["findings"] for row in results)
    print(json.dumps({"status": "FAIL" if failed else "PASS", "kind": "design-md-metadata-shape-check", "results": results,
                      "limits": ["Checks name, group shapes and typography field names only.",
                                 "Does not validate every value, alias, section, DTCG token or source/style fidelity."]}, ensure_ascii=False, indent=2))
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
