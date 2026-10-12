"""Reject malformed typography without inventing missing source values."""
import importlib.util
from pathlib import Path
import tempfile
import unittest

REPO = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location("check_design_metadata", REPO / ".agents/skills/legacy-to-spec/scripts/check_design_metadata.py")
checker = importlib.util.module_from_spec(spec)
spec.loader.exec_module(checker)


class DesignMetadataTests(unittest.TestCase):
    def check(self, yaml):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "DESIGN.md"
            path.write_text("---\n" + yaml + "\n---\n\n## Overview\nSource known only in part.\n")
            return checker.check(path)

    def test_source_only_font_family_object_is_accepted(self):
        self.assertEqual(self.check("name: Page\ntypography:\n  page:\n    fontFamily: sans-serif"), [])

    def test_css_string_typography_entry_is_rejected(self):
        self.assertTrue(any("typography.font-family" in finding for finding in self.check("name: Page\ntypography:\n  font-family: sans-serif")))

    def test_css_property_name_inside_typography_is_rejected(self):
        self.assertTrue(any("font-family" in finding for finding in self.check("name: Page\ntypography:\n  page:\n    font-family: sans-serif")))
