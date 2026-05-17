# AMDP — Example Mandates

**Version:** 0.1.0
**Status:** Draft
**License:** MIT

This folder contains five reference mandate documents covering the breadth of AMDP v0.1.0. Each example pairs a `*.json` mandate file with a `*.md` companion explaining the scenario, the constraints, and why the mandate is shaped this way.

## Index

| Example | Vertical | Scenario |
|---------|----------|----------|
| [advertising-publisher-mandate](advertising-publisher-mandate.json) ([explanation](advertising-publisher-mandate.md)) | `advertising` | Brand X authorizes agent for CHF 5'000 Q2 media buy. |
| [equity-research-family-office](equity-research-family-office.json) ([explanation](equity-research-family-office.md)) | `equity-research` | Family office authorizes agent for mining-equity decisions up to USD 500'000. |
| [procurement-cross-vendor](procurement-cross-vendor.json) ([explanation](procurement-cross-vendor.md)) | `procurement` | Company authorizes agent for whitelisted-vendor orders up to USD 50'000. |
| [multi-vertical-family-office](multi-vertical-family-office.json) ([explanation](multi-vertical-family-office.md)) | `equity-research` + `procurement` (via sub-delegation) | Family-office parent mandate plus a narrowed procurement sub-mandate. |
| [public-services-citizen-request](public-services-citizen-request.json) ([explanation](public-services-citizen-request.md)) | `public-services` | Citizen authorizes agent for tax-form submissions to a municipal portal. |

## Validation

All `*.json` files in this folder MUST validate against the Mandate Document JSON Schema in [SPECIFICATION.md section 2.1](../SPECIFICATION.md#2-mandate-document-schema). You can validate locally with `ajv`:

```bash
# Extract schema (one-time, from SPECIFICATION.md)
# Then validate each example:
npx ajv-cli validate -s mandate.schema.json -d examples/*.json
```

Signature values in these examples are placeholders (string `"base64url:placeholder-..."`) — they are NOT valid signatures. Real signatures require principal key material, which is not included. A future `examples/test-vectors/` folder will include signed mandates with bundled key material for end-to-end signature-verification testing (planned for v0.2.0).

## How to use

These examples are pedagogical, not production-ready. Implementers SHOULD:

1. Read the companion `.md` file to understand the scenario.
2. Inspect the JSON to see how vertical, actions, constraints, and metadata combine.
3. Generate their own mandates using their issuer's key material — do NOT copy mandate IDs or DIDs from these examples.
