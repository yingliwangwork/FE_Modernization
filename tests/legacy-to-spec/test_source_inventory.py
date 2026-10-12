"""Validate metadata evidence on raw bytes, including unreadable input."""
import hashlib
import importlib.util
from pathlib import Path
import tempfile
import unittest

REPO = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location("source_inventory", REPO / "skills/legacy-to-spec/scripts/source_inventory.py")
inventory = importlib.util.module_from_spec(spec)
spec.loader.exec_module(inventory)


class SourceInventoryTests(unittest.TestCase):
    def inspect(self, data):
        with tempfile.TemporaryDirectory() as directory:
            source = Path(directory) / "source"
            source.write_bytes(data)
            result = inventory.inspect(source, ["utf-8", "cp950"])
            self.assertEqual(source.read_bytes(), data)
            return result

    def test_multiple_valid_codecs_do_not_choose_intended_encoding(self):
        result = self.inspect(b"ascii\n")
        self.assertEqual(result["encoding_conclusion"], "unconfirmed")
        self.assertTrue(all(item["status"] == "valid" for item in result["strict_decoding"].values()))

    def test_invalid_bytes_cannot_be_hidden_by_replacement_decoding(self):
        result = self.inspect(b"\xff\xff\n")
        self.assertTrue(all(item["status"] == "invalid" for item in result["strict_decoding"].values()))
        self.assertEqual(result["encoding_conclusion"], "unconfirmed")

    def test_physical_lines_newlines_and_hash_match_raw_bytes(self):
        data = b"one\r\ntwo\nthree\r"
        result = self.inspect(data)
        self.assertEqual(result["physical_lines"], 3)
        self.assertEqual((result["crlf"], result["lf"], result["cr"]), (1, 1, 1))
        self.assertEqual(result["sha256"], hashlib.sha256(data).hexdigest())
