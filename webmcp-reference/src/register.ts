// Registers all Nexbid tools with the WebMCP browser API.
// Feature-detects navigator.modelContext before registering.

import type { WebMcpToolDefinition } from './types';
import { trackToolInvocation } from './analytics';
import { searchOffersTool } from './tools/search-offers';
import { getOfferDetailsTool } from './tools/get-offer-details';
import { listCategoriesTool } from './tools/list-categories';
import { initiateTransactionTool } from './tools/initiate-transaction';
import { getOrderStatusTool } from './tools/get-order-status';

const ALL_TOOLS: WebMcpToolDefinition[] = [
  searchOffersTool,
  getOfferDetailsTool,
  listCategoriesTool,
  initiateTransactionTool,
  getOrderStatusTool,
];

/**
 * Register all Nexbid WebMCP tools if the browser supports it.
 * Safe to call on any browser — returns false if WebMCP is unavailable.
 */
export function registerNexbidWebMcpTools(): boolean {
  if (!('modelContext' in navigator) || !navigator.modelContext) {
    console.debug('[nexbid-webmcp] Browser does not support WebMCP — skipping tool registration');
    return false;
  }

  let registered = 0;
  for (const tool of ALL_TOOLS) {
    try {
      const wrappedTool = {
        ...tool,
        execute: async (params: Record<string, unknown>) => {
          trackToolInvocation(tool.name, params);
          return tool.execute(params);
        },
      };
      navigator.modelContext.registerTool(wrappedTool);
      registered++;
    } catch (err) {
      console.warn(`[nexbid-webmcp] Failed to register tool "${tool.name}":`, err);
    }
  }

  console.info(`[nexbid-webmcp] Registered ${registered}/${ALL_TOOLS.length} tools`);
  return registered > 0;
}
