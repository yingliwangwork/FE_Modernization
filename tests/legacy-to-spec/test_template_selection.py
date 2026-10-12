"""Verify overrides, fallback, provenance and invalid configuration handling."""
import hashlib
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

REPO = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location("select_templates", REPO / ".agent/skills/legacy-to-spec/scripts/select_templates.py")
selector = importlib.util.module_from_spec(spec)
spec.loader.exec_module(selector)


class TemplateSelectionTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name).resolve()

    def tearDown(self):
        self.temp.cleanup()

    def select(self, config):
        path = self.root / "profile.json"
        path.write_text(json.dumps(config))
        return selector.resolve_templates(path)

    def test_defaults_have_real_files_and_provenance(self):
        result = selector.resolve_templates()
        self.assertEqual(result["style_profile"], "design-md")
        for entry in result["templates"].values():
            path = Path(entry["path"])
            self.assertEqual(entry["selected_by"], "builtin")
            self.assertEqual(entry["sha256"], hashlib.sha256(path.read_bytes()).hexdigest())

    def test_override_precedes_custom_root_and_missing_roles_fall_back(self):
        (self.root / "custom/integration").mkdir(parents=True)
        (self.root / "custom/integration/api-spec.md").write_text("root")
        (self.root / "explicit.md").write_text("override")
        result = self.select({"template_root": "custom", "overrides": {"api-spec": "explicit.md"}, "output_root": "delivery"})
        self.assertEqual(Path(result["templates"]["api-spec"]["path"]).read_text(), "override")
        self.assertEqual(result["templates"]["plan"]["selected_by"], "builtin")
        self.assertEqual(result["output_root"], str(self.root / "delivery"))

    def test_custom_root_used_and_its_change_changes_digest(self):
        (self.root / "custom/design").mkdir(parents=True)
        template = self.root / "custom/design/DESIGN.md"
        template.write_text("original")
        first = self.select({"template_root": "custom"})
        template.write_text("changed")
        second = self.select({"template_root": "custom"})
        self.assertEqual(first["templates"]["component-design"]["selected_by"], "project-template-root")
        self.assertNotEqual(first["templates"]["component-design"]["sha256"], second["templates"]["component-design"]["sha256"])

    def test_explicit_missing_override_and_missing_root_fail(self):
        for config in ({"overrides": {"api-spec": "missing.md"}}, {"template_root": "missing"}):
            with self.assertRaises(ValueError):
                self.select(config)

    def test_dtcg_profile_and_domain_reference_are_recorded(self):
        (self.root / "rules.md").write_text("approved source")
        result = self.select({"style_profile": "design-md+dtcg", "references": {"domain": ["rules.md"]}})
        self.assertEqual(result["style_profile"], "design-md+dtcg")
        self.assertEqual(result["references"]["domain"][0]["path"], str(self.root / "rules.md"))

    def test_typos_invalid_profiles_and_missing_references_fail(self):
        for config in ({"overrides": {"api-spce": "x"}}, {"style_profile": "dtgc"}, {"referneces": {}}, {"references": {"ui": ["missing"]}}):
            with self.assertRaises(ValueError):
                self.select(config)


if __name__ == "__main__":
    unittest.main()
