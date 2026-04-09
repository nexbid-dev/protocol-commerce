# Nexbid MCP Server

Agentic commerce infrastructure for AI agents. MCP-native product discovery, contextual ad matching, and purchase facilitation with European privacy compliance (nDSG/GDPR).

## Tools

| Tool | Description |
|------|-------------|
| `nexbid_search` | Search and discover products and recipes |
| `nexbid_product` | Get detailed product information by ID |
| `nexbid_categories` | List available product categories |
| `nexbid_purchase` | Initiate a purchase, get checkout link |
| `nexbid_order_status` | Check purchase intent status |

## Quick Start

```json
{
  "mcpServers": {
    "nexbid": {
      "url": "https://mcp.nexbid.dev/mcp"
    }
  }
}
```

## Production Endpoint

**URL:** `https://mcp.nexbid.dev/mcp`
**Transport:** Streamable HTTP
**Auth:** Optional (API key via `x-api-key` header)

## Local Development

```bash
cd mcp-server
npm install
npm run build
node dist/index.js
```

The local server runs via stdio transport. Use [mcp-proxy](https://github.com/punkpeye/mcp-proxy) for SSE transport.

## License

MIT — [Protocol Commerce](https://github.com/nexbid-dev/protocol-commerce)
