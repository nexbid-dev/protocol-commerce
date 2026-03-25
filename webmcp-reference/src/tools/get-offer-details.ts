import type { WebMcpToolDefinition } from '../types';
import { getProductById } from '../api-client';

export const getOfferDetailsTool: WebMcpToolDefinition = {
  name: 'getOfferDetails',
  description: 'Get full details of a specific product offer by ID. Returns price, availability, description, brand, category, and purchase link.',
  inputSchema: {
    type: 'object',
    properties: {
      offer_id: { type: 'string', description: 'Product UUID from searchOffers' },
    },
    required: ['offer_id'],
  },
  execute: async (params) => {
    try {
      const p = await getProductById(params.offer_id as string);
      const lines = [
        `**${p.title}**`,
        p.brand ? `Brand: ${p.brand}` : null,
        p.category ? `Category: ${p.category}` : null,
        `Price: ${(p.price_cents / 100).toFixed(2)} ${p.currency}`,
        `Availability: ${p.availability}`,
        p.description ? `Description: ${p.description}` : null,
        `Link: ${p.url}`,
      ].filter(Boolean);
      return { content: lines.join('\n') };
    } catch (err) {
      return { content: `Product lookup failed: ${err instanceof Error ? err.message : 'unknown'}`, isError: true };
    }
  },
};
