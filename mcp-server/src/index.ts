import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { z } from 'zod';

const SERVER_DESCRIPTION =
  'Nexbid Agent Discovery — search and discover advertiser products through an open marketplace';

const REMOTE_ENDPOINT = 'https://mcp.nexbid.dev/mcp';

const server = new McpServer(
  {
    name: 'Nexbid',
    version: '0.1.0',
  },
  {
    capabilities: {
      tools: {},
    },
  },
);

// ── Tool: nexbid_search ─────────────────────────────────────────
server.tool(
  'nexbid_search',
  `Search and discover products AND recipes in the Nexbid marketplace. ${SERVER_DESCRIPTION}. Returns ranked results matching the query — products with prices/availability/links, and recipes with ingredients/targeting signals/nutrition.`,
  {
    query: z.string().min(1).max(500).describe('Natural language product or recipe query'),
    content_type: z
      .enum(['all', 'product', 'recipe'])
      .optional()
      .default('all')
      .describe('Filter by content type: product, recipe, or all (default)'),
    intent: z
      .enum(['purchase', 'compare', 'research', 'browse'])
      .optional()
      .describe('User intent for the search'),
    budget_max_cents: z
      .number()
      .int()
      .positive()
      .optional()
      .describe('Maximum budget in cents (e.g. 20000 for CHF 200)'),
    budget_min_cents: z
      .number()
      .int()
      .nonnegative()
      .optional()
      .describe('Minimum budget in cents'),
    currency: z
      .enum(['CHF', 'EUR', 'USD', 'GBP'])
      .optional()
      .describe('Currency for budget filtering'),
    geo: z
      .string()
      .length(2)
      .optional()
      .describe('ISO 3166-1 alpha-2 country code (default: CH)'),
    category: z.string().optional().describe('Filter by product category'),
    brand: z.string().optional().describe('Filter by brand name'),
    max_results: z
      .number()
      .int()
      .min(1)
      .max(50)
      .optional()
      .describe('Maximum number of results (1-50, default: 10)'),
    previous_queries: z
      .array(z.string().max(200))
      .max(10)
      .optional()
      .describe(
        'Previous queries in this search session for multi-turn refinement (oldest first, max 10). Example: ["running shoes", "waterproof only"]',
      ),
  },
  async (params) => ({
    content: [
      {
        type: 'text' as const,
        text: `This is the protocol-commerce reference server. For live results, connect to the production endpoint at ${REMOTE_ENDPOINT}\n\nQuery received: "${params.query}"`,
      },
    ],
  }),
);

// ── Tool: nexbid_product ────────────────────────────────────────
server.tool(
  'nexbid_product',
  'Get detailed product information by ID from the Nexbid marketplace. Returns full product details including price, availability, description, and purchase link.',
  {
    product_id: z.string().uuid().describe('Product UUID'),
  },
  async (params) => ({
    content: [
      {
        type: 'text' as const,
        text: `This is the protocol-commerce reference server. For live results, connect to ${REMOTE_ENDPOINT}\n\nProduct ID: ${params.product_id}`,
      },
    ],
  }),
);

// ── Tool: nexbid_categories ─────────────────────────────────────
server.tool(
  'nexbid_categories',
  'List all available product categories in the Nexbid marketplace with product counts. Optionally filter by country.',
  {
    geo: z
      .string()
      .length(2)
      .optional()
      .describe('ISO 3166-1 alpha-2 country code to filter categories'),
  },
  async () => ({
    content: [
      {
        type: 'text' as const,
        text: `This is the protocol-commerce reference server. For live results, connect to ${REMOTE_ENDPOINT}`,
      },
    ],
  }),
);

// ── Tool: nexbid_purchase ───────────────────────────────────────
server.tool(
  'nexbid_purchase',
  'Initiate a purchase for a product found via nexbid_search. Returns a checkout link that the user can click to complete the purchase at the retailer. The agent should present this link to the user for confirmation.',
  {
    product_id: z.string().uuid().describe('Product UUID to purchase'),
    quantity: z
      .number()
      .int()
      .min(1)
      .max(99)
      .optional()
      .default(1)
      .describe('Quantity to purchase (default: 1)'),
    checkout_mode: z
      .enum(['prefill_link', 'wallet_pay'])
      .optional()
      .describe(
        'Checkout mode. Default: prefill_link. wallet_pay requires a connected wallet with active mandate.',
      ),
  },
  async (params) => ({
    content: [
      {
        type: 'text' as const,
        text: `This is the protocol-commerce reference server. For live results, connect to ${REMOTE_ENDPOINT}\n\nProduct ID: ${params.product_id}`,
      },
    ],
  }),
);

// ── Tool: nexbid_order_status ───────────────────────────────────
server.tool(
  'nexbid_order_status',
  'Check the status of a purchase intent created via nexbid_purchase.',
  {
    intent_id: z.string().uuid().describe('Purchase intent UUID from nexbid_purchase'),
  },
  async (params) => ({
    content: [
      {
        type: 'text' as const,
        text: `This is the protocol-commerce reference server. For live results, connect to ${REMOTE_ENDPOINT}\n\nIntent ID: ${params.intent_id}`,
      },
    ],
  }),
);

// ── Start stdio transport ───────────────────────────────────────
const transport = new StdioServerTransport();
await server.connect(transport);
