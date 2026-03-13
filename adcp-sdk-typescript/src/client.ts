/**
 * AdCP Client
 *
 * A lightweight client for communicating with any AdCP-compatible server.
 * Uses MCP's JSON-RPC 2.0 protocol over HTTP.
 *
 * @module @protocol-commerce/adcp-sdk
 * @version 0.1.0
 * @license MIT
 */

import type {
  AdcpClientConfig,
  SearchParams,
  SearchResponse,
  ProductParams,
  ProductDetail,
  CategoriesParams,
  CategoriesResponse,
  ErrorResponse,
} from './types.js';
import {
  searchParamsSchema,
  productParamsSchema,
  categoriesParamsSchema,
} from './validators.js';

const DEFAULT_TIMEOUT = 10_000; // 10 seconds

/**
 * Client for the Agentic Discovery Commerce Protocol.
 *
 * @example
 * ```typescript
 * const client = new AdcpClient({
 *   serverUrl: 'https://mcp.nexbid.dev',
 *   apiKey: 'your-api-key',
 * });
 *
 * const results = await client.search({ query: 'organic olive oil', geo: 'CH' });
 * console.log(results.products);
 * ```
 */
export class AdcpClient {
  private readonly config: Required<AdcpClientConfig>;

  constructor(config: AdcpClientConfig) {
    this.config = {
      ...config,
      timeout: config.timeout ?? DEFAULT_TIMEOUT,
    };
  }

  /**
   * Search for products.
   *
   * Sends an adcp.search message to the server and returns ranked results.
   * Results may include both organic and sponsored products.
   */
  async search(params: SearchParams): Promise<SearchResponse> {
    const validated = searchParamsSchema.parse(params);
    return this.callTool('adcp.search', validated);
  }

  /**
   * Get product details by ID.
   *
   * Retrieves full product information including geo scope and timestamps.
   */
  async product(params: ProductParams): Promise<ProductDetail> {
    const validated = productParamsSchema.parse(params);
    return this.callTool('adcp.product', validated);
  }

  /**
   * List available product categories.
   *
   * Optionally filter by geography.
   */
  async categories(params?: CategoriesParams): Promise<CategoriesResponse> {
    const validated = categoriesParamsSchema.parse(params ?? {});
    return this.callTool('adcp.categories', validated);
  }

  // ─── Internal ───────────────────────────────────────────────────

  private async callTool<T>(toolName: string, args: Record<string, unknown>): Promise<T> {
    const body = {
      jsonrpc: '2.0',
      id: crypto.randomUUID(),
      method: 'tools/call',
      params: {
        name: toolName,
        arguments: args,
      },
    };

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), this.config.timeout);

    try {
      const response = await fetch(this.config.serverUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': this.config.apiKey,
        },
        body: JSON.stringify(body),
        signal: controller.signal,
      });

      if (!response.ok) {
        const errorText = await response.text().catch(() => 'Unknown error');
        throw new AdcpError(
          `HTTP ${response.status}: ${errorText}`,
          response.status === 401
            ? 'UNAUTHORIZED'
            : response.status === 429
              ? 'RATE_LIMITED'
              : 'INTERNAL_ERROR',
        );
      }

      const json = await response.json();

      if (json.error) {
        throw new AdcpError(
          json.error.message ?? 'Unknown JSON-RPC error',
          'INTERNAL_ERROR',
        );
      }

      return json.result as T;
    } catch (error) {
      if (error instanceof AdcpError) throw error;
      if (error instanceof DOMException && error.name === 'AbortError') {
        throw new AdcpError('Request timed out', 'INTERNAL_ERROR');
      }
      throw new AdcpError(
        error instanceof Error ? error.message : 'Unknown error',
        'INTERNAL_ERROR',
      );
    } finally {
      clearTimeout(timeoutId);
    }
  }
}

/**
 * AdCP-specific error with protocol error code.
 */
export class AdcpError extends Error {
  readonly code: ErrorResponse['code'];

  constructor(message: string, code: ErrorResponse['code']) {
    super(message);
    this.name = 'AdcpError';
    this.code = code;
  }
}
