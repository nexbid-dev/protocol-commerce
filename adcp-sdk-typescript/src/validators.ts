/**
 * AdCP Zod Validators
 *
 * Runtime validation schemas for AdCP protocol messages.
 * Use these to validate inputs before sending requests
 * or to validate server responses.
 *
 * @module @protocol-commerce/adcp-sdk
 * @version 0.1.0
 * @license MIT
 */

import { z } from 'zod';

// ─── Enum Schemas ───────────────────────────────────────────────────

export const currencySchema = z.enum(['CHF', 'EUR', 'USD', 'GBP']);

export const availabilitySchema = z.enum(['in_stock', 'out_of_stock', 'preorder']);

export const searchIntentSchema = z.enum(['purchase', 'compare', 'research', 'browse']);

export const agentTypeSchema = z.enum(['claude', 'chatgpt', 'gemini', 'custom', 'unknown']);

export const eventTypeSchema = z.enum(['impression', 'click', 'add_to_cart', 'purchase']);

export const errorCodeSchema = z.enum([
  'NOT_FOUND',
  'INVALID_INPUT',
  'RATE_LIMITED',
  'UNAUTHORIZED',
  'INTERNAL_ERROR',
]);

// ─── Geo Code ───────────────────────────────────────────────────────

/** ISO 3166-1 alpha-2 country code (uppercase, 2 chars) */
export const geoSchema = z
  .string()
  .length(2)
  .transform((v) => v.toUpperCase())
  .refine((v) => /^[A-Z]{2}$/.test(v), {
    message: 'Must be a valid ISO 3166-1 alpha-2 country code',
  });

// ─── Price ──────────────────────────────────────────────────────────

export const priceSchema = z.object({
  amount: z.number().nonnegative(),
  currency: currencySchema,
});

// ─── Search ─────────────────────────────────────────────────────────

export const searchParamsSchema = z.object({
  query: z.string().min(1).max(500),
  intent: searchIntentSchema.optional(),
  geo: geoSchema.optional(),
  category: z.string().optional(),
  brand: z.string().optional(),
  budget_min_cents: z.number().int().nonnegative().optional(),
  budget_max_cents: z.number().int().positive().optional(),
  currency: currencySchema.optional(),
  max_results: z.number().int().min(1).max(50).optional(),
});

export const productResultSchema = z.object({
  id: z.string().uuid(),
  title: z.string(),
  description: z.string().nullable(),
  url: z.string().url(),
  imageUrl: z.string().url().nullable(),
  price: priceSchema,
  category: z.string().nullable(),
  brand: z.string().nullable(),
  availability: availabilitySchema,
  score: z.number().min(0).max(1),
  sponsored: z.boolean().optional().default(false),
});

export const searchResponseSchema = z.object({
  products: z.array(productResultSchema),
  totalMatches: z.number().int().nonnegative(),
  latencyMs: z.number().nonnegative(),
});

// ─── Product Detail ─────────────────────────────────────────────────

export const productParamsSchema = z.object({
  product_id: z.string().uuid(),
});

export const productDetailSchema = productResultSchema.extend({
  geoScope: z.array(z.string().length(2)),
  createdAt: z.string().datetime(),
  updatedAt: z.string().datetime(),
});

// ─── Categories ─────────────────────────────────────────────────────

export const categoriesParamsSchema = z.object({
  geo: geoSchema.optional(),
});

export const categoryEntrySchema = z.object({
  category: z.string(),
  productCount: z.number().int().nonnegative(),
});

export const categoriesResponseSchema = z.object({
  categories: z.array(categoryEntrySchema),
});

// ─── Attribution ────────────────────────────────────────────────────

export const attributionEventSchema = z.object({
  eventType: eventTypeSchema,
  productId: z.string().uuid(),
  campaignId: z.string().uuid(),
  queryId: z.string().uuid(),
  placementId: z.string().optional(),
  agentType: agentTypeSchema.optional(),
  geo: geoSchema.optional(),
  sourceUrl: z.string().url().optional(),
});

// ─── Error ──────────────────────────────────────────────────────────

export const errorResponseSchema = z.object({
  error: z.string(),
  code: errorCodeSchema,
});

// ─── Scoring ────────────────────────────────────────────────────────

export const scoringWeightsSchema = z
  .object({
    bid: z.number().min(0).max(1),
    relevance: z.number().min(0).max(1),
    quality: z.number().min(0).max(1),
  })
  .refine((w) => Math.abs(w.bid + w.relevance + w.quality - 1.0) < 0.001, {
    message: 'Scoring weights must sum to 1.0',
  });

// ─── Inferred Types ─────────────────────────────────────────────────

export type SearchParamsInput = z.infer<typeof searchParamsSchema>;
export type ProductResultOutput = z.infer<typeof productResultSchema>;
export type SearchResponseOutput = z.infer<typeof searchResponseSchema>;
export type ProductParamsInput = z.infer<typeof productParamsSchema>;
export type ProductDetailOutput = z.infer<typeof productDetailSchema>;
export type CategoriesParamsInput = z.infer<typeof categoriesParamsSchema>;
export type CategoriesResponseOutput = z.infer<typeof categoriesResponseSchema>;
export type AttributionEventInput = z.infer<typeof attributionEventSchema>;
export type ScoringWeightsInput = z.infer<typeof scoringWeightsSchema>;
