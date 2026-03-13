/**
 * @protocol-commerce/adcp-sdk
 *
 * TypeScript SDK for the Agentic Discovery Commerce Protocol (AdCP).
 * An open protocol for agent-native commerce, built on MCP.
 *
 * @version 0.1.0
 * @license MIT
 * @see https://github.com/nexbid-dev/protocol-commerce
 */

// Client
export { AdcpClient, AdcpError } from './client.js';

// Types
export type {
  Currency,
  Availability,
  SearchIntent,
  AgentType,
  EventType,
  Price,
  SearchParams,
  ProductResult,
  SearchResponse,
  ProductParams,
  ProductDetail,
  CategoriesParams,
  CategoryEntry,
  CategoriesResponse,
  AttributionEvent,
  ScoringWeights,
  ErrorCode,
  ErrorResponse,
  AdcpClientConfig,
} from './types.js';

export { DEFAULT_SCORING_WEIGHTS } from './types.js';

// Validators
export {
  currencySchema,
  availabilitySchema,
  searchIntentSchema,
  agentTypeSchema,
  eventTypeSchema,
  errorCodeSchema,
  geoSchema,
  priceSchema,
  searchParamsSchema,
  productResultSchema,
  searchResponseSchema,
  productParamsSchema,
  productDetailSchema,
  categoriesParamsSchema,
  categoryEntrySchema,
  categoriesResponseSchema,
  attributionEventSchema,
  errorResponseSchema,
  scoringWeightsSchema,
} from './validators.js';

// Inferred validator types
export type {
  SearchParamsInput,
  ProductResultOutput,
  SearchResponseOutput,
  ProductParamsInput,
  ProductDetailOutput,
  CategoriesParamsInput,
  CategoriesResponseOutput,
  AttributionEventInput,
  ScoringWeightsInput,
} from './validators.js';
