#!/usr/bin/env python3
"""
AMDP Example Validator
======================

Validates the JSON examples in `amdp-spec/examples/` against:

  1. The JSON Schema in SPECIFICATION.md Section 2.1 (extracted at runtime)
  2. Conformance rules from CONFORMANCE.md and SPECIFICATION.md that require
     cross-field or semantic checks (not expressible in pure JSON Schema):

     - I-2  mandate_id MUST be UUID v7
     - I-6  expires_at MUST NOT be more than 12 months after issued_at
     - 4.5  Action identifiers MUST be defined for the mandate's vertical
     - 5.7  Constraint `data_classes` is defined only for public-services

Usage:
  python3 tools/validate-examples.py
  python3 tools/validate-examples.py --quiet     # only failures
  python3 tools/validate-examples.py --json      # machine-readable output

Exit codes:
  0  all examples conform
  1  one or more conformance failures
  2  spec or example files unreadable
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import dataclass, field
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Any

try:
    from jsonschema import Draft202012Validator
except ImportError:
    sys.stderr.write(
        "ERROR: jsonschema not installed. Install with: pip3 install jsonschema\n"
    )
    sys.exit(2)


SPEC_DIR = Path(__file__).resolve().parent.parent
EXAMPLES_DIR = SPEC_DIR / "examples"
SPEC_FILE = SPEC_DIR / "SPECIFICATION.md"

# Actions per vertical, per SPECIFICATION.md section 4
ACTIONS_BY_VERTICAL: dict[str, set[str]] = {
    "advertising": {
        "create_media_buy",
        "pause_campaign",
        "submit_creative",
        "approve_invoice",
    },
    "procurement": {
        "approve_order",
        "select_vendor",
        "negotiate_terms",
    },
    "equity-research": {
        "make_investment_decision",
        "rebalance_portfolio",
        "subscribe_research_report",
    },
    "public-services": {
        "submit_request",
        "approve_form",
        "query_records",
    },
}

# Constraint keys that are vertical-specific, per SPECIFICATION.md section 5
VERTICAL_SPECIFIC_CONSTRAINTS: dict[str, set[str]] = {
    "data_classes": {"public-services"},
}


@dataclass
class Finding:
    example: str
    severity: str  # "error" | "warning"
    rule: str
    message: str


@dataclass
class ExampleResult:
    file: str
    findings: list[Finding] = field(default_factory=list)

    @property
    def ok(self) -> bool:
        return not any(f.severity == "error" for f in self.findings)


def extract_schema(spec_text: str) -> dict[str, Any]:
    """Extract the JSON Schema from SPECIFICATION.md section 2.1.

    The schema is the first ```json ... ``` fenced block after the
    `### 2.1 JSON Schema` heading.
    """
    marker = re.search(r"^### 2\.1 JSON Schema", spec_text, re.MULTILINE)
    if not marker:
        raise RuntimeError(
            "Could not find section '### 2.1 JSON Schema' in SPECIFICATION.md"
        )
    after = spec_text[marker.end():]
    fence = re.search(r"```json\s*\n(.*?)\n```", after, re.DOTALL)
    if not fence:
        raise RuntimeError(
            "No ```json ... ``` fenced block found after section 2.1 heading"
        )
    return json.loads(fence.group(1))


def check_expires_window(example: dict[str, Any]) -> list[Finding]:
    """I-6: expires_at MUST NOT exceed 12 months after issued_at."""
    out: list[Finding] = []
    iso_issued = example.get("issued_at")
    iso_expires = example.get("expires_at")
    if not iso_issued or not iso_expires:
        return out
    try:
        issued = datetime.fromisoformat(iso_issued.replace("Z", "+00:00"))
        expires = datetime.fromisoformat(iso_expires.replace("Z", "+00:00"))
    except ValueError as e:
        out.append(
            Finding("", "error", "I-6", f"date parse failed: {e}")
        )
        return out
    delta = expires - issued
    # 12 months ~ 366 days (allow leap year)
    max_window = timedelta(days=366)
    if delta > max_window:
        out.append(
            Finding(
                "",
                "error",
                "I-6",
                f"expires_at is {delta.days} days after issued_at "
                f"(MUST be <= 366 days per spec section 2.1 / Issuer rule I-6)",
            )
        )
    if delta.total_seconds() <= 0:
        out.append(
            Finding(
                "",
                "error",
                "I-6",
                f"expires_at ({iso_expires}) is not after issued_at ({iso_issued})",
            )
        )
    return out


def check_action_vertical_consistency(example: dict[str, Any]) -> list[Finding]:
    """Section 4.5: actions[] MUST be defined for scope.vertical."""
    out: list[Finding] = []
    scope = example.get("scope", {})
    vertical = scope.get("vertical")
    actions = scope.get("actions", [])
    valid = ACTIONS_BY_VERTICAL.get(vertical, set())
    for action in actions:
        if action not in valid:
            out.append(
                Finding(
                    "",
                    "error",
                    "4.5",
                    f"action '{action}' is not defined for vertical "
                    f"'{vertical}' (valid actions: {sorted(valid)})",
                )
            )
    return out


def check_vertical_specific_constraints(
    example: dict[str, Any],
) -> list[Finding]:
    """Section 5: constraints flagged as vertical-specific MUST appear only
    in mandates for that vertical."""
    out: list[Finding] = []
    scope = example.get("scope", {})
    vertical = scope.get("vertical")
    constraints = scope.get("constraints", {})
    for key, allowed_verticals in VERTICAL_SPECIFIC_CONSTRAINTS.items():
        if key in constraints and vertical not in allowed_verticals:
            out.append(
                Finding(
                    "",
                    "warning",
                    "5",
                    f"constraint '{key}' is documented only for verticals "
                    f"{sorted(allowed_verticals)} but appears in '{vertical}' mandate",
                )
            )
    return out


def check_delegation_chain(example: dict[str, Any]) -> list[Finding]:
    """Section 2.1: each delegation_chain entry MUST be UUID v7. (Schema
    catches this; we add a friendlier message for the common case.)
    """
    out: list[Finding] = []
    chain = example.get("delegation_chain", [])
    uuid_v7 = re.compile(
        r"^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$"
    )
    for idx, entry in enumerate(chain):
        if not isinstance(entry, str) or not uuid_v7.match(entry):
            out.append(
                Finding(
                    "",
                    "error",
                    "2.1",
                    f"delegation_chain[{idx}] is not a UUID v7: {entry!r}",
                )
            )
    return out


def validate_example(
    path: Path, validator: Draft202012Validator
) -> ExampleResult:
    result = ExampleResult(file=path.name)
    try:
        example = json.loads(path.read_text(encoding="utf-8"))
    except Exception as e:
        result.findings.append(
            Finding(path.name, "error", "parse", f"failed to read/parse: {e}")
        )
        return result

    # 1. Schema validation
    for error in validator.iter_errors(example):
        loc = "/".join(str(p) for p in error.absolute_path) or "<root>"
        result.findings.append(
            Finding(
                path.name,
                "error",
                "schema",
                f"at {loc}: {error.message}",
            )
        )

    # 2. Cross-field conformance
    for finding in (
        *check_expires_window(example),
        *check_action_vertical_consistency(example),
        *check_vertical_specific_constraints(example),
        *check_delegation_chain(example),
    ):
        finding.example = path.name
        result.findings.append(finding)

    return result


def print_human(results: list[ExampleResult], quiet: bool) -> None:
    total = len(results)
    failed = [r for r in results if not r.ok]
    warned = [r for r in results if r.ok and r.findings]
    passed = [r for r in results if r.ok and not r.findings]

    if not quiet:
        for r in results:
            status = "PASS" if r.ok else "FAIL"
            print(f"[{status}] {r.file}")
            for f in r.findings:
                tag = "ERROR" if f.severity == "error" else "WARN"
                print(f"    {tag} [{f.rule}] {f.message}")
    else:
        for r in failed + warned:
            status = "FAIL" if not r.ok else "WARN"
            print(f"[{status}] {r.file}")
            for f in r.findings:
                tag = "ERROR" if f.severity == "error" else "WARN"
                print(f"    {tag} [{f.rule}] {f.message}")

    print()
    print(
        f"Summary: {len(passed)} pass, {len(warned)} warnings only, "
        f"{len(failed)} failed (total: {total})"
    )


def print_json(results: list[ExampleResult]) -> None:
    out = [
        {
            "file": r.file,
            "ok": r.ok,
            "findings": [
                {
                    "severity": f.severity,
                    "rule": f.rule,
                    "message": f.message,
                }
                for f in r.findings
            ],
        }
        for r in results
    ]
    print(json.dumps(out, indent=2))


def main() -> int:
    ap = argparse.ArgumentParser(description="Validate AMDP example mandates")
    ap.add_argument("--quiet", action="store_true", help="only show failures + warnings")
    ap.add_argument("--json", action="store_true", help="machine-readable JSON output")
    args = ap.parse_args()

    try:
        schema = extract_schema(SPEC_FILE.read_text(encoding="utf-8"))
    except (RuntimeError, json.JSONDecodeError) as e:
        sys.stderr.write(f"ERROR loading schema from SPECIFICATION.md: {e}\n")
        return 2

    validator = Draft202012Validator(schema)

    examples = sorted(EXAMPLES_DIR.glob("*.json"))
    if not examples:
        sys.stderr.write(f"ERROR: no examples found in {EXAMPLES_DIR}\n")
        return 2

    results = [validate_example(p, validator) for p in examples]

    if args.json:
        print_json(results)
    else:
        print_human(results, quiet=args.quiet)

    return 0 if all(r.ok for r in results) else 1


if __name__ == "__main__":
    sys.exit(main())
