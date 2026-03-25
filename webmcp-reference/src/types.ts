// WebMCP API type definitions (Chrome 146+ DevTrial)

/** JSON Schema subset used by WebMCP tool input definitions */
export interface JsonSchema {
  type: string;
  properties?: Record<string, JsonSchema & {
    description?: string;
    enum?: string[];
    minimum?: number;
    maximum?: number;
    default?: unknown;
  }>;
  required?: string[];
}

/** WebMCP Tool definition passed to navigator.modelContext.registerTool() */
export interface WebMcpToolDefinition {
  name: string;
  description: string;
  inputSchema: JsonSchema;
  execute: (params: Record<string, unknown>) => Promise<WebMcpToolResult>;
}

/** Result returned from a WebMCP tool execution */
export interface WebMcpToolResult {
  content: string;
  isError?: boolean;
}

/** Extend Navigator interface for WebMCP */
declare global {
  interface Navigator {
    modelContext?: {
      registerTool: (tool: WebMcpToolDefinition) => void;
    };
  }
}
