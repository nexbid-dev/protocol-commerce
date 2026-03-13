# Changelog

All notable changes to the AdCP specification will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] — 2026-03-13

### Added

- Initial draft specification
- Discovery messages: `adcp.search`, `adcp.product`, `adcp.categories`
- Scoring model with public formula: `score = 0.4×bid + 0.4×relevance + 0.2×quality`
- Attribution model with UUID v7 query identifiers
- Privacy model: context signals only, no user identifiers
- Interoperability overview: MCP (native), OpenRTB/Prebid/ARTF/GPP (planned bridges)
- JSON Schema definitions for search params, product results, and attribution events
- Planned auction messages: `adcp.bid`, `adcp.decision`, `adcp.report` (v0.2.0)
