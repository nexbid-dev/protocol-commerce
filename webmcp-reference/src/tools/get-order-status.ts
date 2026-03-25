import type { WebMcpToolDefinition } from '../types';
import { getOrderStatus } from '../api-client';

export const getOrderStatusTool: WebMcpToolDefinition = {
  name: 'getOrderStatus',
  description: 'Check the status of a previously initiated purchase transaction. Requires the intent_id returned by initiateTransaction.',
  inputSchema: {
    type: 'object',
    properties: {
      intent_id: { type: 'string', description: 'Purchase intent UUID from initiateTransaction' },
    },
    required: ['intent_id'],
  },
  execute: async (params) => {
    try {
      const status = await getOrderStatus(params.intent_id as string);
      const lines = [
        `Status: ${status.status}`,
        `Product: ${status.product_title}`,
        `Price: ${status.price}`,
        status.checkout_url ? `Checkout: ${status.checkout_url}` : null,
        `Created: ${status.created_at}`,
        status.expires_at ? `Expires: ${status.expires_at}` : null,
      ].filter(Boolean);
      return { content: lines.join('\n') };
    } catch (err) {
      return { content: `Status check failed: ${err instanceof Error ? err.message : 'unknown'}`, isError: true };
    }
  },
};
