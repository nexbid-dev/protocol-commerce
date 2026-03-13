/**
 * AdCP Protocol Types
 *
 * Core type definitions for the Agentic Discovery Commerce Protocol.
 * These types define the protocol messages — they are independent of
 * any specific server implementation.
 *
 * @module @protocol-commerce/adcp-sdk
 * @version 0.1.0
 * @license MIT
 */

// ─── Domain Primitives ─────────────────────────────────────────────

/** Supported currencies */
export type Currency = 'CHF' | 'EUR' | 'USD' | 'GBP';

/** Product availability status */
export type Availability = 'in_stock' | 'out_of_stock' | 'preorder';

/** Agent search intent classification */
export type SearchIntent = 'purchase' | 'compare' | 'research' | 'browse';

/** AI agent type identifier */
export type AgentType = 'claude' | 'chatgpt' | 'gemini' | 'custom' | 'unknown';

/** Attribution event types */
export type EventType = 'impression' | 'click' | 'add_to_cart' | 'purchase';

// ─── Price ──────────────────────────────────────────────────────────

/** Price object with display amount and currency */
export interface Price {
  /** Display price (not cents). Example: 19.90 */
  amount: number;
  /** ISO currency code */
  currency: Currency;
}

// ─── Search ─────────────────────────────────────────────────────────

/** Parameters for adcp.search */
export interface SearchParams {
  /** Natural language search query (1-500 chars) */
  query: string;
  /** User intent classification */
  intent?: SearchIntent;
  /** ISO 3166-1 alpha-2 country code (e.g., 'CH', 'DE') */
  geo?: string;
  /** Product category filter */
  category?: string;
  /** Brand name filter */
  brand?: string;
  /** Minimum price in cents */
  budget_min_cents?: number;
  /** Maximum price in cents */
  budget_max_cents?: number;
  /** Currency for budget filtering */
  currency?: Currency;
  /** Maximum results to return (1-50, default 10) */
  max_results?: number;
}

/** A single product in search results */
export interface ProductResult {
  /** Unique product identifier (UUID) */
  id: string;
  /** Product title */
  title: string;
  /** Product description */
  description: string | null;
  /** Product page URL (merchant site) */
  url: string;
  /** Product image URL */
  imageUrl: string | null;
  /** Product price */
  price: Price;
  /** Product category */
  category: string | null;
  /** Brand name */
  brand: string | null;
  /** Availability status */
  availability: Availability;
  /** Relevance/auction score (0.0 to 1.0) */
  score: number;
  /** Whether this is a paid/sponsored result */
  sponsored?: boolean;
}

/** Response from adcp.search */
export interface SearchResponse {
  /** Ranked product results */
  products: ProductResult[];
  /** Total number of matching products */
  totalMatches: number;
  /** Server-side processing time in milliseconds */
  latencyMs: number;
}

// ─── Product Detail ─────────────────────────────────────────────────

/** Parameters for adcp.product */
export interface ProductParams {
  /** Product UUID */
  product_id: string;
}

/** Extended product details */
export interface ProductDetail extends ProductResult {
  /** Available geographies (ISO 3166-1 alpha-2 codes) */
  geoScope: string[];
  /** When the product was first indexed */
  createdAt: string;
  /** When the product was last updated */
  updatedAt: string;
}

// ─── Categories ─────────────────────────────────────────────────────

/** Parameters for adcp.categories */
export interface CategoriesParams {
  /** ISO 3166-1 alpha-2 country code to filter categories */
  geo?: string;
}

/** A category with product count */
export interface CategoryEntry {
  /** Category name */
  category: string;
  /** Number of products in this category */
  productCount: number;
}

/** Response from adcp.categories */
export interface CategoriesResponse {
  categories: CategoryEntry[];
}

// ─── Attribution ────────────────────────────────────────────────────

/** Attribution event (tracks value, not users) */
export interface AttributionEvent {
  /** Type of event */
  eventType: EventType;
  /** Product involved */
  productId: string;
  /** Campaign that funded the placement */
  campaignId: string;
  /** UUID v7 linking to the original search query */
  queryId: string;
  /** Publisher placement identifier */
  placementId?: string;
  /** Which AI agent served the result */
  agentType?: AgentType;
  /** ISO 3166-1 alpha-2 country code */
  geo?: string;
  /** Where the interaction occurred */
  sourceUrl?: string;
}

// ─── Scoring ────────────────────────────────────────────────────────

/** Scoring weights configuration */
export interface ScoringWeights {
  /** Weight for bid component (default: 0.4) */
  bid: number;
  /** Weight for relevance/similarity component (default: 0.4) */
  relevance: number;
  /** Weight for quality signal component (default: 0.2) */
  quality: number;
}

/** Default scoring weights */
export const DEFAULT_SCORING_WEIGHTS: ScoringWeights = {
  bid: 0.4,
  relevance: 0.4,
  quality: 0.2,
};

// ─── Errors ─────────────────────────────────────────────────────────

/** Standard error codes */
export type ErrorCode =
  | 'NOT_FOUND'
  | 'INVALID_INPUT'
  | 'RATE_LIMITED'
  | 'UNAUTHORIZED'
  | 'INTERNAL_ERROR';

/** Standard error response */
export interface ErrorResponse {
  /** Human-readable error message */
  error: string;
  /** Machine-readable error code */
  code: ErrorCode;
}

// ─── Client Configuration ───────────────────────────────────────────

/** Configuration for an AdCP client */
export interface AdcpClientConfig {
  /** AdCP server URL (e.g., 'https://mcp.nexbid.dev') */
  serverUrl: string;
  /** API key for authentication */
  apiKey: string;
  /** Request timeout in milliseconds (default: 10000) */
  timeout?: number;
}
