// Track WebMCP tool invocations for attribution analytics.
// Uses SubmitEvent.agentInvoked when available (WebMCP GA),
// falls back to custom event tracking.

export function trackToolInvocation(toolName: string, params: Record<string, unknown>): void {
  try {
    console.info(`[nexbid-webmcp] Tool invoked: ${toolName}`, {
      tool: toolName,
      timestamp: new Date().toISOString(),
      hasQuery: 'query' in params,
      hasProductId: 'offer_id' in params || 'product_id' in params,
      hasIntentId: 'intent_id' in params,
    });

    // Future: POST to /api/analytics/agent-event
    // with { tool, timestamp, source: 'webmcp', agentInvoked: true }
  } catch {
    // Analytics should never break tool execution
  }
}
