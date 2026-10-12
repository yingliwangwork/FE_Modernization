"""Ensure structural validation rejects damaged sandbox packages.

These fixtures test the harness, not the skill's semantic quality. Actual LLM
trials and independent source-based reviews are preserved separately.
"""
import contextlib
import importlib.util
import io
import json
from pathlib import Path
import tempfile
import types
import unittest

REPO = Path(__file__).resolve().parents[2]
module_spec = importlib.util.spec_from_file_location("skill_sandbox", REPO / "scripts/skill-sandbox.py")
harness = importlib.util.module_from_spec(module_spec)
module_spec.loader.exec_module(harness)


class SandboxHarnessTests(unittest.TestCase):
    def setUp(self):
        parent = REPO / "sandbox/legacy-to-spec"
        parent.mkdir(parents=True, exist_ok=True)
        self.directory = tempfile.TemporaryDirectory(prefix="validator-test-", dir=parent)
        self.case = Path(self.directory.name)
        self.source = REPO / "tests/legacy-to-spec/fixtures/coupled/frontend/Case.jsp"
        snapshot = self.case / "inputs/Case.jsp"
        snapshot.parent.mkdir()
        snapshot.write_bytes(self.source.read_bytes())
        manifest = {"case": "afy10400", "run": "validator-test", "scope_id": "test",
                    "files": [{"path": "inputs/Case.jsp", "origin": str(self.source),
                               "category": "source", "sha256": harness.digest(self.source)}]}
        (self.case / "manifest.json").write_text(json.dumps(manifest))
        self.spec = self.write("artifacts/design/test/specification.md", "# 規格\n\nSCR-01 ST-01 UI-01\n")
        self.write("artifacts/renovation/test/tracking.md", "# 追蹤\n\n### TODO-01\n")
        self.write("artifacts/integration/test/api-spec.md", "# 介接\n")
        self.prototype = self.write("artifacts/design/test/prototypes/screen.html", """<!doctype html>
<html><body><main data-scope-id="test" data-screen-id="SCR-01" data-state-id="ST-01">
<span data-ui-id="UI-01">已知元素</span></main><script>const valid = true;</script></body></html>""")

    def tearDown(self):
        self.directory.cleanup()

    def write(self, relative, content):
        file = self.case / relative
        file.parent.mkdir(parents=True, exist_ok=True)
        file.write_text(content)
        return file

    def check(self):
        with contextlib.redirect_stdout(io.StringIO()):
            result = harness.check(types.SimpleNamespace(case_dir=str(self.case)))
        report = json.loads((self.case / "reports/structure.json").read_text())
        return result, report

    def assertRejected(self, code):
        result, report = self.check()
        self.assertEqual(result, 1)
        self.assertIn(code, [finding["code"] for finding in report["findings"]])

    def test_well_formed_package_has_only_structural_pass(self):
        result, report = self.check()
        self.assertEqual(result, 0)
        self.assertEqual(report["kind"], "structural-and-input-integrity-check")
        self.assertTrue(report["limits"])

    def test_modified_input_is_rejected_and_original_preserved(self):
        before = harness.digest(self.source)
        (self.case / "inputs/Case.jsp").write_text("tampered")
        self.assertRejected("SNAPSHOT_CHANGED")
        self.assertEqual(harness.digest(self.source), before)

    def test_unfilled_template_is_rejected(self):
        self.spec.write_text("# {{unfinished}}\n")
        self.assertRejected("UNFILLED_TEMPLATE")

    def test_unfilled_component_css_and_tokens_are_rejected(self):
        css = self.write("artifacts/design/test/styles/CMP-01.css", "/* {{STYLE-ID}} */")
        self.assertRejected("UNFILLED_TEMPLATE")
        css.write_text("/* no style is defined */")
        self.write("artifacts/design/test/styles/tokens.json", '{"description": "{{source}}"}')
        self.assertRejected("UNFILLED_TEMPLATE")

    def test_missing_todo_anchor_is_rejected(self):
        self.spec.write_text("# 規格\nUI-01\n[TODO](../../renovation/test/tracking.md#todo-99)\n")
        self.assertRejected("BROKEN_ANCHOR")

    def test_case_escape_is_rejected(self):
        self.spec.write_text("# 規格\nUI-01\n[escape](../../../../../../README.md)\n")
        self.assertRejected("LINK_ESCAPES_CASE")

    def test_invalid_generated_javascript_is_rejected(self):
        self.prototype.write_text(self.prototype.read_text().replace("const valid = true;", "const = ;"))
        self.assertRejected("INVALID_JAVASCRIPT")

    def test_wrong_prototype_scope_is_rejected(self):
        self.prototype.write_text(self.prototype.read_text().replace('data-scope-id="test"', 'data-scope-id="other"'))
        self.assertRejected("WRONG_PROTOTYPE_SCOPE")

    def test_new_run_requires_a_separate_plan(self):
        path = self.case / "manifest.json"
        manifest = json.loads(path.read_text())
        manifest["schema_version"] = 2
        path.write_text(json.dumps(manifest))
        self.assertRejected("MISSING_DELIVERABLE")
        self.write("artifacts/renovation/test/plan.md", "# 計劃\n\n依賴盤點待辦。\n")
        result, report = self.check()
        self.assertEqual(result, 0)

    def test_prepare_defaults_to_awaiting_dependency_decisions(self):
        import shutil
        import uuid
        run = "policy-test-" + uuid.uuid4().hex
        target = REPO / "sandbox/legacy-to-spec" / run
        try:
            with contextlib.redirect_stdout(io.StringIO()):
                harness.prepare(types.SimpleNamespace(case="coupled", run=run, backend_root=None))
            manifest = json.loads((target / "coupled/manifest.json").read_text())
            self.assertEqual(manifest["dependency_policy"], "ask")
            self.assertEqual(manifest["schema_version"], 2)
            self.assertIn("No dependency expansion or deferral decision is pre-authorized", (target / "coupled/task.txt").read_text())
            self.assertFalse((target / "coupled/artifacts").exists())
        finally:
            if target.exists():
                shutil.rmtree(target)

    def test_authorized_dependency_scope_uses_its_own_specification(self):
        path = self.case / "manifest.json"
        manifest = json.loads(path.read_text())
        manifest["dependency_policy"] = "convert-available"
        path.write_text(json.dumps(manifest))
        self.write("artifacts/design/dependency/specification.md", "# 相依契約\nSCR-DEP ST-DEP UI-DEP\n")
        self.write("artifacts/renovation/dependency/plan.md", "# 相依計劃\n")
        self.write("artifacts/renovation/dependency/tracking.md", "# 相依追蹤\n")
        html = self.write("artifacts/design/dependency/prototypes/dependency.html", '<main data-scope-id="dependency" data-screen-id="SCR-DEP" data-state-id="ST-DEP"><span data-ui-id="UI-DEP">相依內容</span></main>')
        self.assertEqual(self.check()[0], 0)
        html.write_text(html.read_text().replace("UI-DEP", "UI-01"))
        self.assertRejected("UNMAPPED_PROTOTYPE_ID")

    def test_deferred_dependency_cannot_add_another_conversion_scope(self):
        self.write("artifacts/design/dependency/specification.md", "SCR-DEP ST-DEP UI-DEP\n")
        self.write("artifacts/design/dependency/prototypes/dependency.html", '<main data-scope-id="dependency" data-screen-id="SCR-DEP" data-state-id="ST-DEP"></main>')
        self.assertRejected("UNAUTHORIZED_DEPENDENCY_SCOPE")


if __name__ == "__main__":
    unittest.main()
