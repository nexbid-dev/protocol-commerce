import type { WebMcpToolDefinition } from '../types';
import { createPurchaseIntent } from '../api-client';

export const initiateTransactionTool: WebMcpToolDefinition = {
  name: 'initiateTransaction',
  description: 'Start a purchase transaction for a selected product offer. Returns a checkout URL that the user can click to complete the purchase at the retailer. Requires user confirmation before proceeding.',
  inputSchema: {
    type: 'object',
    properties: {
      offer_id: { type: 'string', description: 'Product UUID to purchase' },
      quantity: { type: 'number', description: 'Quantity to purchase (default: 1)', minimum: 1, maximum: 99, default: 1 },
    },
    required: ['offer_id'],
  },
  execute: async (params) => {
    try {
      const result = await createPurchaseIntent(params.offer_id as string, (params.quantity as number) ?? 1);
      return {
        content: [
          `Transaction initiated for: ${result.product_title}`,
          `Price: ${result.price}`,
          `Checkout: ${result.checkout_url}`,
          `Intent ID: ${result.intent_id}`,
          `Mode: ${result.mode}`,
        ].join('\n'),
      };
    } catch (err) {
      return { content: `Transaction failed: ${err instanceof Error ? err.message : 'unknown'}`, isError: true };
    }
  },
};
