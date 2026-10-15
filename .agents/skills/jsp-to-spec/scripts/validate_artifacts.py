#!/usr/bin/env python3
"""Check output structure and common static-HTML violations, not semantic equivalence."""
import argparse
from html.parser import HTMLParser
from pathlib import Path
import re
import sys
from urllib.parse import unquote, urlsplit


PLACEHOLDER = re.compile(r"{{.*?}}|<%|\$\{[^}]*}", re.S)
CSS_DYNAMIC = re.compile(
    r"@import\b|@font-face\b|expression\s*\(|-moz-binding|behavior\s*:", re.I
)


def check_css(css, errors):
    css = re.sub(r"/\*.*?\*/", "", css, flags=re.S)
    # Escaped identifiers can conceal imports/URLs; this checker accepts plain CSS only.
    if "\\" in css or CSS_DYNAMIC.search(css):
        errors.append("CSS contains an import, executable/escaped rule or external font")
    for target in re.findall(r"url\s*\((.*?)\)", css, re.I | re.S):
        if not target.strip(" \t\r\n'\"").startswith("#"):
            errors.append("CSS URL must be an in-document fragment")


class StaticPage(HTMLParser):
    def __init__(self, filename, known_files):
        super().__init__(convert_charrefs=True)
        self.filename = filename
        self.known_files = known_files
        self.errors = []
        self.counts = {}
        self.state_id = None
        self.style_depth = 0
        self.style_text = []
        self.doctype = False

    def handle_decl(self, decl):
        if decl.lower() == "doctype html":
            self.doctype = True

    def handle_starttag(self, tag, attrs):
        self.counts[tag] = self.counts.get(tag, 0) + 1
        attributes = dict(attrs)
        if tag in {"script", "iframe", "object", "embed", "base", "link", "form"}:
            self.errors.append(f"forbidden <{tag}>; use static sections and inline CSS")
        if tag == "style":
            self.style_depth += 1
        if tag == "body":
            self.state_id = attributes.get("data-state-id")
        if tag == "meta" and (attributes.get("http-equiv") or "").lower() == "refresh":
            self.errors.append("meta refresh is not static")
        if tag == "button" and (attributes.get("type") or "").lower() != "button":
            self.errors.append("buttons must explicitly use type=button")
        if tag == "input" and (attributes.get("type") or "").lower() in {"submit", "image"}:
            self.errors.append("submitting input is forbidden")
        for name, value in attrs:
            value = value or ""
            if name.startswith("on") or name in {"srcdoc", "action", "formaction", "srcset"}:
                self.errors.append(f"active attribute {name} is forbidden")
            if name.startswith(("v-", "x-", "ng-")) or name.startswith((":", "@")):
                self.errors.append(f"framework directive {name} is forbidden")
            if name == "style":
                check_css(value, self.errors)
            if name in {"src", "href", "xlink:href", "poster", "data", "background"}:
                if value.startswith("#"):
                    continue
                parsed = urlsplit(value)
                if (tag == "a" and name == "href" and not parsed.scheme
                        and not parsed.netloc and not parsed.query
                        and unquote(parsed.path) in self.known_files
                        and Path(unquote(parsed.path)).name == unquote(parsed.path)):
                    continue
                if (tag == "img" and name == "src"
                        and re.fullmatch(r"data:image/(?:png|jpeg|gif|webp);base64,[A-Za-z0-9+/=\s]+", value)):
                    continue
                self.errors.append(f"resource/navigation must be embedded or a local state HTML: {name}")

    def handle_startendtag(self, tag, attrs):
        self.handle_starttag(tag, attrs)
        self.handle_endtag(tag)

    def handle_endtag(self, tag):
        if tag == "style" and self.style_depth:
            self.style_depth -= 1

    def handle_data(self, data):
        if self.style_depth:
            self.style_text.append(data)

    def finish(self):
        check_css("".join(self.style_text), self.errors)
        if not self.doctype:
            self.errors.append("missing <!doctype html>")
        for tag in ("html", "head", "body", "title"):
            if self.counts.get(tag) != 1:
                self.errors.append(f"expected exactly one <{tag}>")
        if not re.fullmatch(r"S-\d+", self.state_id or ""):
            self.errors.append("body needs data-state-id=S-<number>")
        elif not self.filename.endswith(f".{self.state_id}.html"):
            self.errors.append("filename and data-state-id differ")


def validate(root, spec_name):
    errors = []
    if not root.is_dir():
        return ["output directory does not exist"]
    if Path(spec_name).name != spec_name or not spec_name.endswith(".spec.md"):
        return ["--spec must be a basename ending in .spec.md"]
    entries = list(root.iterdir())
    for entry in entries:
        if entry.is_symlink() or not entry.is_file():
            errors.append(f"unexpected directory/symlink: {entry.name}")
        elif entry.name != spec_name and entry.suffix != ".html":
            errors.append(f"unexpected artifact: {entry.name}")
    # Do not read any linked file or directory, even on a failing run.
    files = [p for p in entries if p.is_file() and not p.is_symlink()]
    specs = [p for p in files if p.name == spec_name]
    html_files = [p for p in files if p.suffix == ".html"]
    if len(specs) != 1:
        errors.append("expected the specified spec file")
    if not html_files:
        errors.append("expected at least one static HTML state")
    names = {p.name for p in html_files}
    state_ids = set()
    for path in html_files:
        content = path.read_text(encoding="utf-8")
        page = StaticPage(path.name, names)
        page.feed(content)
        page.close()
        page.finish()
        if PLACEHOLDER.search(content):
            page.errors.append("unexpanded template/JSP expression")
        if page.state_id in state_ids:
            page.errors.append("duplicate state ID")
        state_ids.add(page.state_id)
        errors.extend(f"{path.name}: {error}" for error in page.errors)
        stem = spec_name.removesuffix(".spec.md")
        if not path.name.startswith(stem + "."):
            errors.append(f"{path.name}: filename does not use the spec page name")
    if specs:
        content = specs[0].read_text(encoding="utf-8")
        # Raw JSP/EL is permitted in source evidence, unlike executable visual HTML.
        if re.search(r"{{.*?}}", content, re.S):
            errors.append("spec contains unexpanded template placeholders")
        linked = set()
        # The supplied template uses inline Markdown links to state files.
        for target in re.findall(r"\[[^\]\n]*\]\(([^)\n]+)\)", content):
            parsed = urlsplit(target.strip("<>"))
            if parsed.path.endswith(".html"):
                filename = unquote(parsed.path)
                if parsed.scheme or parsed.netloc or parsed.query or filename not in names:
                    errors.append(f"spec state link is not a delivered local HTML: {target}")
                else:
                    linked.add(filename)
        for filename in sorted(names - linked):
            errors.append(f"{filename}: missing Markdown link from spec")
        if not content.strip():
            errors.append("spec is empty")
    return errors


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path)
    parser.add_argument("--spec", required=True)
    args = parser.parse_args()
    try:
        errors = validate(args.output, args.spec)
    except (OSError, UnicodeError, ValueError) as exc:
        errors = [f"cannot validate: {exc}"]
    if errors:
        for error in errors:
            print(f"FAIL: {error}", file=sys.stderr)
        return 1
    print("PASS: artifact structure and static HTML checks.")
    print("Semantic coverage, reachable states and visual layout still require review.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
