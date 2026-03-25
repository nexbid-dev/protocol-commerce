import type { WebMcpToolDefinition } from '../types';
import { searchProducts } from '../api-client';

export const searchOffersTool: WebMcpToolDefinition = {
  name: 'searchOffers',
  description:
    'Search for available product offers in the Nexbid marketplace. ' +
    'Accepts a product query, optional budget range in cents, geo filter (ISO country code), ' +
    'category, brand, and intent. Returns a ranked list of offers with price, availability, and ID.',
  inputSchema: {
    type: 'object',
    properties: {
      query: { type: 'string', description: 'Natural language product query' },
      geo: { type: 'string', description: 'ISO 3166-1 alpha-2 country code (default: CH)' },
      category: { type: 'string', description: 'Filter by product category' },
      brand: { type: 'string', description: 'Filter by brand name' },
      budget_min_cents: { type: 'number', description: 'Minimum budget in cents', minimum: 0 },
      budget_max_cents: { type: 'number', description: 'Maximum budget in cents', minimum: 1 },
      limit: { type: 'number', description: 'Max results (1-50, default: 10)', minimum: 1, maximum: 50 },
      intent: { type: 'string', description: 'User intent', enum: ['purchase', 'compare', 'research', 'browse'] },
    },
    required: ['query'],
  },
  execute: async (params) => {
    try {
      const result = await searchProducts({
        query: params.query as string,
        geo: params.geo as string | undefined,
        category: params.category as string | undefined,
        brand: params.brand as string | undefined,
        budget_min_cents: params.budget_min_cents as number | undefined,
        budget_max_cents: params.budget_max_cents as number | undefined,
        limit: params.limit as number | undefined,
        intent: params.intent as string | undefined,
      });
      if (result.products.length === 0) {
        return { content: `No products found for "${params.query}".` };
      }
      const lines = result.products.map((p, i) =>
        `${i + 1}. ${p.title}${p.brand ? ` (${p.brand})` : ''} — ` +
        `${(p.price_cents / 100).toFixed(2)} ${p.currency} — ${p.availability} — ID: ${p.id}`
      );
      return { content: `Found ${result.totalMatches} products:\n${lines.join('\n')}` };
    } catch (err) {
      return { content: `Search failed: ${err instanceof Error ? err.message : 'unknown'}`, isError: true };
    }
  },
};
