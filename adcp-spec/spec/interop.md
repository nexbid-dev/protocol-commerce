# AdCP Interoperability

**Version:** 0.1.0

## Design Principle

AdCP does not replace existing ad-tech standards. It adds an agent-native layer that bridges to existing infrastructure through adapters.

## Architecture

```
┌─────────────────────────────────────────────┐
│                AI Agents                     │
│   Claude │ ChatGPT │ Gemini │ Custom         │
├─────────────────────────────────────────────┤
│              MCP Transport                   │
│          JSON-RPC 2.0 / HTTP                 │
├─────────────────────────────────────────────┤
│         AdCP Protocol Layer                  │
│   adcp.search │ adcp.product │ adcp.bid      │
├──────────┬──────────┬───────────┬───────────┤
│ OpenRTB  │ Prebid   │ ARTF     │ GPP/TCF    │
│ Bridge   │ Adapter  │ Bridge   │ Layer      │
├──────────┴──────────┴───────────┴───────────┤
│       Existing Programmatic Infra            │
│   DSPs │ SSPs │ Ad Exchanges │ GAM           │
└─────────────────────────────────────────────┘
```

## MCP (Native — Available Now)

AdCP is built on MCP. Every AdCP server is a valid MCP server.

**Transport:** JSON-RPC 2.0 over Streamable HTTP
**Authentication:** API key (`x-api-key` header or `Authorization: Bearer`)
**Discovery:** Standard MCP `tools/list` for capability negotiation
**Supported MCP versions:** 2024-11-05 and later

### MCP Tool Mapping

| AdCP Message | MCP Tool Name | Category |
|-------------|---------------|----------|
| `adcp.search` | Implementation-defined (e.g., `nexbid_search`) | Discovery |
| `adcp.product` | Implementation-defined (e.g., `nexbid_product`) | Discovery |
| `adcp.categories` | Implementation-defined (e.g., `nexbid_categories`) | Discovery |
| `adcp.bid` | Implementation-defined | Auction (v0.2.0) |
| `adcp.report` | Implementation-defined | Attribution (v0.2.0) |

Note: MCP tool names are implementation-specific. The AdCP message types define the semantics; the MCP tool name is the binding.

## OpenRTB 2.6 Bridge (Planned — Q4 2026)

### Purpose

Allow existing programmatic buyers (DSPs) to participate in AdCP auctions through an OpenRTB-compatible interface.

### Mapping

| OpenRTB Concept | AdCP Equivalent |
|----------------|-----------------|
| Bid Request | `adcp.search` result → OpenRTB bid request |
| Bid Response | OpenRTB bid → `adcp.bid` |
| Win Notice | `adcp.decision` → OpenRTB win URL |
| Impression | `adcp.report` (eventType: impression) |
| Click | `adcp.report` (eventType: click) |

### Key Differences

| Aspect | OpenRTB 2.6 | AdCP |
|--------|------------|------|
| Latency target | <100ms | 100-500ms (agent interaction is slower) |
| User data | Device ID, IP, cookies | None (context only) |
| Auction type | Second-price (legacy) or first-price | First-price sealed-bid |
| Format | JSON over HTTP POST | JSON-RPC 2.0 over MCP |

### Bridge Behavior

The OpenRTB bridge translates between protocols:

1. AdCP search creates an auction opportunity
2. Bridge generates an OpenRTB bid request from the AdCP context (without user data)
3. DSPs respond with standard OpenRTB bids
4. Bridge translates bids into AdCP bid format
5. AdCP auction engine evaluates all bids (native + bridged)
6. Win/loss notifications sent through both protocols

## Prebid.js Adapter (Planned — Q4 2026)

### Purpose

Allow publishers using Prebid.js for header bidding to include AdCP-compatible demand sources.

### Integration

```javascript
// prebid-config.js (planned)
pbjs.addAdUnits([{
  code: 'ad-slot-1',
  bids: [{
    bidder: 'adcp',
    params: {
      serverUrl: 'https://api.example.com',
      apiKey: 'pub-key-123',
      placementId: 'search-main',
      geo: 'CH'
    }
  }]
}]);
```

The Prebid adapter translates Prebid bid requests into AdCP searches and returns bids in Prebid-compatible format.

## ARTF v1.0 Bridge (Planned — Q4 2026)

### Purpose

Compatibility with IAB Tech Lab's Agentic Real-Time Framework for high-volume bidding scenarios.

### Key Differences

| Aspect | ARTF v1.0 | AdCP |
|--------|----------|------|
| Transport | gRPC / Protocol Buffers | JSON-RPC 2.0 / MCP |
| Latency | <50ms | 100-500ms |
| Focus | Real-time bidding at scale | Agent-native discovery |
| Governance | IAB Tech Lab | Community (MIT) |

The ARTF bridge enables AdCP servers to participate in ARTF auctions for high-volume programmatic scenarios while maintaining AdCP's privacy model.

## GPP 1.1 / TCF 2.2 (Planned — Q4 2026)

### Purpose

Regulatory compliance layer for GDPR (EU) and CCPA (US) when AdCP interoperates with identity-based systems.

### How It Works

AdCP itself does not process personal data for targeting. However, when bridging to OpenRTB or other identity-based systems:

1. GPP/TCF consent signals are parsed from the request
2. If consent is absent or denied, the bridge operates in context-only mode (AdCP native behavior)
3. If consent is present, the bridge MAY pass limited signals to identity-based demand partners
4. The AdCP server itself never stores or processes the consent data

This ensures that AdCP's privacy model is maintained even when interoperating with less privacy-focused systems.

## Implementing a Bridge

Bridge implementations follow the adapter pattern:

```typescript
interface ProtocolBridge<TRequest, TResponse> {
  /** Translate external request to AdCP format */
  toAdcp(request: TRequest): AdcpSearchParams;

  /** Translate AdCP results to external format */
  fromAdcp(results: AdcpSearchResponse): TResponse;

  /** Protocol-specific configuration */
  config: BridgeConfig;
}
```

Bridge implementations will be available as separate npm packages under the `@protocol-commerce` scope.
