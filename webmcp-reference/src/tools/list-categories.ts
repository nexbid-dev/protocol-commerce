import type { WebMcpToolDefinition } from '../types';
import { listCategories } from '../api-client';

export const listCategoriesTool: WebMcpToolDefinition = {
  name: 'listCategories',
  description: 'List all available product categories in the Nexbid marketplace with product counts. Optionally filter by country code.',
  inputSchema: {
    type: 'object',
    properties: {
      geo: { type: 'string', description: 'ISO 3166-1 alpha-2 country code to filter categories' },
    },
  },
  execute: async (params) => {
    try {
      const categories = await listCategories(params.geo as string | undefined);
      if (categories.length === 0) return { content: 'No categories found.' };
      const lines = categories.map((c) => `- ${c.category} (${c.product_count} products)`);
      return { content: `Available categories:\n${lines.join('\n')}` };
    } catch (err) {
      return { content: `Category listing failed: ${err instanceof Error ? err.message : 'unknown'}`, isError: true };
    }
  },
};
