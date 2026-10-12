#!/usr/bin/env python3
"""Report byte facts and strict decoding results without guessing an encoding."""
import argparse
import codecs
import hashlib
import json
from pathlib import Path


def inspect(path, candidates):
    data = path.read_bytes()
    result = {"path": str(path), "sha256": hashlib.sha256(data).hexdigest(),
              "bytes": len(data), "physical_lines": len(data.splitlines()),
              "line_basis": "raw bytes splitlines; terminal newline adds no extra line",
              "crlf": data.count(b"\r\n"), "lf": data.count(b"\n") - data.count(b"\r\n"),
              "cr": data.count(b"\r") - data.count(b"\r\n"),
              "encoding_conclusion": "unconfirmed", "strict_decoding": {}}
    for candidate in candidates:
        codec = codecs.lookup(candidate).name
        try:
            data.decode(codec, errors="strict")
            result["strict_decoding"][codec] = {"status": "valid"}
        except UnicodeDecodeError as error:
            result["strict_decoding"][codec] = {"status": "invalid", "byte_offset": error.start}
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("files", nargs="+", type=Path)
    parser.add_argument("--candidate", action="append", required=True,
                        help="Repeatable candidate codec; validity does not prove intended encoding")
    args = parser.parse_args()
    print(json.dumps({"files": [inspect(path, args.candidate) for path in args.files],
                      "limits": ["Strict decode validity is not proof of intended encoding or readable meaning.",
                                 "No input files changed; no replacement decoding used."]},
                     ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
