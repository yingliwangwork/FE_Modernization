"""Verify selector contracts and scaffold integrity, not skill execution behavior.

Fixture files stay in a test-owned workspace directory and are removed afterward.
"""
import hashlib
from html.parser import HTMLParser
import importlib.util
import json
from pathlib import Path
import shutil
import subprocess
import sys
import unittest
import uuid


SCRIPT = Path(__file__).resolve().parents[1] / "select_templates.py"
SKILL_ROOT = SCRIPT.parents[1]
UNSET = object()
SPEC = importlib.util.spec_from_file_location("select_templates", SCRIPT)
selector = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(selector)


class TemplateSelectorTests(unittest.TestCase):
    def setUp(self):
        self.fixture = Path(".selector-fixtures-" + uuid.uuid4().hex)
        self.fixture.mkdir()
        self.addCleanup(shutil.rmtree, self.fixture)

    def write_file(self, relative, content="custom template\n"):
        path = self.fixture / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")
        return path

    def config(self, config):
        return self.write_file("config.json", json.dumps(config))

    def resolve(self, config=UNSET, phase="spec", **kwargs):
        config_path = self.config(config) if config is not UNSET else None
        return selector.resolve_templates(config_path, phase=phase, **kwargs)

    def test_default_spec_selects_exactly_four_roles_and_no_stack(self):
        result = self.resolve()
        self.assertEqual(result["phase"], "spec")
        self.assertEqual(result["schema_version"], 2)
        self.assertEqual(list(result["templates"]), ["api-spec", "ui-spec", "prd", "bdd"])
        self.assertNotIn("prototype_stack", result)
        self.assertNotIn("style_profile", result)
        self.assertEqual(result["output_root"], str(Path("artifacts").resolve()))
        self.assertFalse((self.fixture / "artifacts").exists())

    def test_vanilla_prototype_selects_exactly_three_roles(self):
        result = self.resolve(phase="prototype")
        self.assertEqual(result["phase"], "prototype")
        self.assertEqual(result["prototype_stack"], "html-css-javascript")
        self.assertEqual(list(result["templates"]), ["prototype", "prototype-css", "prototype-js"])
        self.assertTrue(all(row["origin"] == "builtin" for row in result["templates"].values()))

    def test_builtin_paths_and_hashes(self):
        for phase in ("spec", "prototype"):
            with self.subTest(phase=phase):
                result = self.resolve(phase=phase)
                for role, row in result["templates"].items():
                    path = (SKILL_ROOT / "templates" / selector.ROLES[role]).resolve()
                    self.assertEqual(row["path"], str(path))
                    self.assertEqual(row["sha256"], hashlib.sha256(path.read_bytes()).hexdigest())
                    self.assertEqual(row["origin"], "builtin")

    def test_explicit_override_beats_custom_root_and_builtin(self):
        override = self.write_file("ui.md", "override\n")
        self.write_file("custom/spec/ui-spec.md", "root\n")
        result = self.resolve({"template_root": "custom", "overrides": {"ui-spec": "ui.md"}})
        row = result["templates"]["ui-spec"]
        self.assertEqual(row["path"], str(override.resolve()))
        self.assertEqual(row["origin"], "explicit-override")
        self.assertEqual(row["sha256"], hashlib.sha256(override.read_bytes()).hexdigest())

    def test_custom_root_beats_builtin_and_records_missing_fallbacks(self):
        custom = self.write_file("custom/spec/ui-spec.md", "root\n")
        result = self.resolve({"template_root": "custom"})
        self.assertEqual(result["templates"]["ui-spec"]["path"], str(custom.resolve()))
        self.assertEqual(result["templates"]["ui-spec"]["origin"], "project-template-root")
        self.assertEqual(result["templates"]["api-spec"]["origin"], "builtin")
        fallback_limits = [text for text in result["limits"] if "fell back" in text]
        self.assertEqual(len(fallback_limits), 3)
        self.assertTrue(any("spec/api-spec.md" in text for text in fallback_limits))

    def test_missing_explicit_override_never_falls_back(self):
        self.write_file("custom/spec/api-spec.md")
        with self.assertRaisesRegex(ValueError, "不存在或不是檔案"):
            self.resolve({"template_root": "custom", "overrides": {"api-spec": "missing.md"}})

    def test_override_directory_fails(self):
        with self.assertRaisesRegex(ValueError, "不存在或不是檔案"):
            self.resolve({"overrides": {"ui-spec": "."}})

    def test_requested_override_path_type_fails(self):
        for value in ("", "  ", None, [], 123):
            with self.subTest(value=value):
                with self.assertRaisesRegex(ValueError, "overrides.ui-spec.*非空字串"):
                    self.resolve({"overrides": {"ui-spec": value}})

    def test_other_phase_overrides_are_not_resolved_or_path_validated(self):
        for value in ("missing", "", None, []):
            with self.subTest(value=value):
                result = self.resolve({"overrides": {"prototype": value}})
                self.assertEqual(list(result["templates"]), list(selector.PHASE_ROLES["spec"]))
                result = self.resolve({"overrides": {"api-spec": value}}, phase="prototype")
                self.assertEqual(list(result["templates"]), list(selector.PHASE_ROLES["prototype"]))

    def test_both_phase_override_keys_are_accepted(self):
        self.write_file("api.md")
        self.write_file("entry.html")
        config = {"overrides": {"api-spec": "api.md", "prototype": "entry.html"}}
        self.assertEqual(self.resolve(config)["templates"]["api-spec"]["origin"], "explicit-override")
        result = self.resolve(config, phase="prototype")
        self.assertEqual(result["templates"]["prototype"]["origin"], "explicit-override")

    def test_spec_does_not_read_prototype_builtins(self):
        root = self.fixture / "skill"
        for role in selector.PHASE_ROLES["spec"]:
            self.write_file("skill/templates/" + selector.ROLES[role])
        result = self.resolve(skill_root=root)
        self.assertEqual(len(result["templates"]), 4)

    def test_unknown_config_key_fails(self):
        with self.assertRaisesRegex(ValueError, "未知設定欄位: guessed"):
            self.resolve({"guessed": True})

    def test_unknown_role_fails_even_in_unrequested_phase(self):
        for phase in ("spec", "prototype"):
            with self.subTest(phase=phase):
                with self.assertRaisesRegex(ValueError, "未知 overrides 角色: tokens"):
                    self.resolve({"overrides": {"tokens": "missing"}}, phase=phase)

    def test_legacy_style_profile_has_migration_diagnostic(self):
        for value in ("design-md", "design-md+dtcg", None):
            with self.subTest(value=value):
                with self.assertRaisesRegex(ValueError, "style_profile 已移除.*ui-spec.*prototype_stack"):
                    self.resolve({"style_profile": value})

    def test_config_and_overrides_must_be_objects(self):
        for value in ([], None, True, "object"):
            with self.subTest(config=value):
                with self.assertRaisesRegex(ValueError, "設定必須是 JSON object"):
                    self.resolve(value)
        for value in ([], None, "object"):
            with self.subTest(overrides=value):
                with self.assertRaisesRegex(ValueError, "overrides 必須"):
                    self.resolve({"overrides": value})

    def test_missing_or_file_template_root_has_explicit_diagnostic(self):
        self.write_file("not-directory")
        for value in ("missing", "not-directory"):
            with self.subTest(value=value):
                with self.assertRaisesRegex(ValueError, "template_root 不存在或不是目錄"):
                    self.resolve({"template_root": value})

    def test_empty_root_paths_fail(self):
        for key in ("template_root", "output_root"):
            with self.subTest(key=key):
                with self.assertRaisesRegex(ValueError, key + ".*非空字串"):
                    self.resolve({key: ""})

    def test_existing_file_output_root_fails_explicitly(self):
        self.write_file("not-directory")
        with self.assertRaisesRegex(ValueError, "output_root 不是目錄"):
            self.resolve({"output_root": "not-directory"})

    def test_missing_skill_root_has_explicit_diagnostic(self):
        with self.assertRaisesRegex(ValueError, "skill_root 不存在或不是目錄"):
            self.resolve(skill_root=self.fixture / "missing")

    def test_nonfile_custom_slot_fails_instead_of_fallback(self):
        (self.fixture / "custom/spec/ui-spec.md").mkdir(parents=True)
        with self.assertRaisesRegex(ValueError, "不存在或不是檔案"):
            self.resolve({"template_root": "custom"})

    def test_broken_custom_symlink_fails_instead_of_fallback(self):
        slot = self.fixture / "custom/spec/ui-spec.md"
        slot.parent.mkdir(parents=True)
        slot.symlink_to("missing.md")
        with self.assertRaisesRegex(ValueError, "不存在或不是檔案"):
            self.resolve({"template_root": "custom"})

    def test_custom_stack_cannot_use_vanilla_entry(self):
        with self.assertRaisesRegex(ValueError, "overrides.prototype.*禁止回退 vanilla"):
            self.resolve({"prototype_stack": "react-typescript"}, phase="prototype")

    def test_custom_stack_missing_root_entry_fails(self):
        (self.fixture / "custom").mkdir()
        with self.assertRaisesRegex(ValueError, "prototype/prototype.html"):
            self.resolve({"prototype_stack": "react-typescript", "template_root": "custom"},
                         phase="prototype")

    def test_custom_stack_requires_only_custom_entry_not_vanilla_bundles(self):
        entry = self.write_file("Screen.tsx", "export const Screen = null;\n")
        result = self.resolve({"prototype_stack": "react-typescript",
                               "overrides": {"prototype": "Screen.tsx"}}, phase="prototype")
        self.assertEqual(list(result["templates"]), ["prototype"])
        self.assertEqual(result["templates"]["prototype"]["path"], str(entry.resolve()))
        self.assertEqual(result["templates"]["prototype"]["origin"], "explicit-override")
        self.assertEqual(result["prototype_stack"], "react-typescript")
        self.assertTrue(any("no vanilla fallbacks" in text for text in result["limits"]))

    def test_custom_stack_optional_bundles_are_only_supplied_slots(self):
        self.write_file("Screen.tsx")
        self.write_file("logic.ts")
        result = self.resolve({"prototype_stack": "react-typescript",
                               "overrides": {"prototype": "Screen.tsx", "prototype-js": "logic.ts"}},
                              phase="prototype")
        self.assertEqual(list(result["templates"]), ["prototype", "prototype-js"])
        self.assertNotIn("prototype-css", result["templates"])

    def test_custom_stack_can_use_canonical_custom_root_slots(self):
        self.write_file("custom/prototype/prototype.html", "custom stack entry content\n")
        self.write_file("custom/prototype/prototype.css", "custom stack bundle\n")
        result = self.resolve({"prototype_stack": "custom-stack", "template_root": "custom"},
                              phase="prototype")
        self.assertEqual(list(result["templates"]), ["prototype", "prototype-css"])
        self.assertTrue(all(row["origin"] == "project-template-root"
                            for row in result["templates"].values()))
        self.assertFalse(any("fell back" in text for text in result["limits"]))

    def test_custom_stack_explicit_missing_bundle_fails(self):
        self.write_file("Screen.tsx")
        with self.assertRaisesRegex(ValueError, "不存在或不是檔案"):
            self.resolve({"prototype_stack": "react-typescript",
                          "overrides": {"prototype": "Screen.tsx", "prototype-css": "missing"}},
                         phase="prototype")

    def test_stack_string_is_validated_without_guessing_instructions(self):
        for value in ("", "  ", None, []):
            with self.subTest(value=value):
                with self.assertRaisesRegex(ValueError, "prototype_stack 必須是非空字串"):
                    self.resolve({"prototype_stack": value}, phase="prototype")
        result = self.resolve({"prototype_stack": "unresolved-stack"})
        self.assertNotIn("prototype_stack", result)
        self.assertEqual(len(result["templates"]), 4)

    def test_reference_groups_and_hashes(self):
        reference = self.write_file("rules.md", "authority\n")
        config_path = self.config({"references": {kind: ["rules.md"] for kind in ("api", "ui", "domain")}})
        result = selector.resolve_templates(config_path)
        self.assertEqual(result["config"], str(config_path.resolve()))
        self.assertEqual(result["config_sha256"], hashlib.sha256(config_path.read_bytes()).hexdigest())
        for rows in result["references"].values():
            self.assertEqual(rows, [{"path": str(reference.resolve()),
                                     "sha256": hashlib.sha256(reference.read_bytes()).hexdigest()}])

    def test_invalid_references_fail(self):
        for value in ([], {"other": []}, {"api": "file"}, {"ui": ["missing"]}):
            with self.subTest(value=value):
                with self.assertRaises(ValueError):
                    self.resolve({"references": value})

    def test_output_layout_is_scoped_and_creates_nothing(self):
        result = self.resolve({"output_root": "deliveries"})
        root = (self.fixture / "deliveries").resolve()
        self.assertEqual(result["output_root"], str(root))
        layout = result["output_layout"]
        self.assertEqual(layout["scope_root"], str(root / "<scope>"))
        self.assertEqual(layout["history"],
                         {kind: str(root / "<scope>/history" / kind)
                          for kind in ("planning", "draft", "review", "evidence")})
        self.assertEqual(layout["deliverables"],
                         {kind: str(root / "<scope>/deliverables" / kind)
                          for kind in ("spec", "prd", "bdd", "prototype")})
        self.assertFalse(root.exists())

    def test_invalid_phase_fails(self):
        with self.assertRaisesRegex(ValueError, "未知 phase"):
            self.resolve(phase="all")

    def test_cli_json_defaults_and_phase_option(self):
        for args, phase in (([], "spec"), (["--phase", "prototype"], "prototype")):
            with self.subTest(phase=phase):
                run = subprocess.run([sys.executable, str(SCRIPT), *args],
                                     capture_output=True, text=True, check=False)
                self.assertEqual(run.returncode, 0, run.stderr)
                self.assertEqual(json.loads(run.stdout)["phase"], phase)

    def test_cli_explicit_config_failure_is_stderr_nonzero(self):
        config = self.config({"overrides": {"prd": "missing"}})
        run = subprocess.run([sys.executable, str(SCRIPT), "--config", str(config)],
                             capture_output=True, text=True, check=False)
        self.assertEqual(run.returncode, 1)
        self.assertEqual(run.stdout, "")
        self.assertIn("不存在或不是檔案", run.stderr)

    def test_cli_malformed_json_and_invalid_phase_fail(self):
        config = self.write_file("malformed.json", "{")
        for args in (["--config", str(config)], ["--phase", "all"], ["--config", ""]):
            with self.subTest(args=args):
                run = subprocess.run([sys.executable, str(SCRIPT), *args],
                                     capture_output=True, text=True, check=False)
                self.assertNotEqual(run.returncode, 0)
                self.assertEqual(run.stdout, "")
                self.assertTrue(run.stderr.strip())
                self.assertNotIn("Traceback", run.stderr)


class BuiltinResourceTests(unittest.TestCase):
    def test_only_seven_canonical_templates_exist(self):
        root = SKILL_ROOT / "templates"
        files = {str(path.relative_to(root)) for path in root.rglob("*") if path.is_file()}
        self.assertEqual(files, set(selector.ROLES.values()))
        self.assertEqual({path.name for path in root.iterdir()}, {"spec", "prototype"})

    def test_prototype_links_local_assets_and_has_no_business_controls(self):
        class Inspector(HTMLParser):
            def __init__(self):
                super().__init__()
                self.nodes = []

            def handle_starttag(self, tag, attrs):
                self.nodes.append((tag, dict(attrs)))

        root = SKILL_ROOT / "templates/prototype"
        parser = Inspector()
        parser.feed((root / "prototype.html").read_text(encoding="utf-8"))
        links = [attrs["href"] for tag, attrs in parser.nodes if tag == "link"]
        scripts = [attrs.get("src") for tag, attrs in parser.nodes if tag == "script"]
        self.assertEqual(links, ["prototype.css"])
        self.assertEqual(scripts, ["prototype.js"])
        self.assertTrue(all((root / path).is_file() for path in links + scripts))
        self.assertFalse(any(tag in {"button", "input", "form", "style", "iframe"}
                             for tag, _ in parser.nodes))
        self.assertFalse(any("style" in attrs for _, attrs in parser.nodes))
        main = next(attrs for tag, attrs in parser.nodes if tag == "main")
        for key in ("data-ui-id", "data-flow-id", "data-state-id"):
            self.assertTrue(main[key].startswith("{{"))
        self.assertEqual(main["data-template-only"], "true")
        js = (root / "prototype.js").read_text(encoding="utf-8")
        for forbidden in ("fetch(", "XMLHttpRequest", "WebSocket", "addEventListener("):
            self.assertNotIn(forbidden, js)

    def test_prd_and_bdd_preserve_contract_fields_without_invented_scenarios(self):
        root = SKILL_ROOT / "templates/spec"
        prd = (root / "prd.md").read_text(encoding="utf-8")
        self.assertIn("## 2. User Story", prd)
        self.assertIn("## 3. Use Case", prd)
        bdd = (root / "bdd.feature").read_text(encoding="utf-8")
        content = [line.strip() for line in bdd.splitlines()
                   if line.strip() and not line.lstrip().startswith("#")]
        self.assertIn("@template_only @evidence_pending", content)
        self.assertEqual(sum(line.startswith("Feature:") for line in content), 1)
        self.assertFalse(any(line.startswith(("Scenario:", "Scenario Outline:", "Background:"))
                             for line in content))


if __name__ == "__main__":
    unittest.main()
