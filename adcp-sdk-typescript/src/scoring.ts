/**
 * AdCP Scoring Utilities
 *
 * Reference implementation of the AdCP scoring formula.
 * Use this to calculate or verify auction scores.
 *
 * @module @protocol-commerce/adcp-sdk
 * @version 0.1.0
 * @license MIT
 */

import type { ScoringWeights } from './types.js';
import { DEFAULT_SCORING_WEIGHTS } from './types.js';

/**
 * Calculate the AdCP auction score for a sponsored product.
 *
 * Formula: score = (W_bid × normalized_bid) + (W_relevance × similarity) + (W_quality × quality)
 *
 * @param normalizedBid - Bid normalized to 0-1 range (bid / max_bid_in_auction)
 * @param similarity - Semantic similarity between query and product (0-1)
 * @param quality - Campaign quality signal (0-1)
 * @param weights - Scoring weights (defaults to 0.4 / 0.4 / 0.2)
 * @returns Composite score (0-1)
 *
 * @example
 * ```typescript
 * const score = calculateScore(0.8, 0.75, 0.6);
 * // score = 0.4 * 0.8 + 0.4 * 0.75 + 0.2 * 0.6 = 0.74
 * ```
 */
export function calculateScore(
  normalizedBid: number,
  similarity: number,
  quality: number,
  weights: ScoringWeights = DEFAULT_SCORING_WEIGHTS,
): number {
  const score =
    weights.bid * clamp(normalizedBid) +
    weights.relevance * clamp(similarity) +
    weights.quality * clamp(quality);

  return Math.round(score * 1000) / 1000; // 3 decimal places
}

/**
 * Normalize a bid relative to the maximum bid in the auction.
 *
 * @param bidCents - The bid in cents
 * @param maxBidCents - The highest bid in the auction (in cents)
 * @returns Normalized bid (0-1). Returns 1.0 if maxBidCents is 0.
 */
export function normalizeBid(bidCents: number, maxBidCents: number): number {
  if (maxBidCents <= 0) return 1.0;
  return clamp(bidCents / maxBidCents);
}

/** Clamp a value to 0-1 range */
function clamp(value: number): number {
  return Math.max(0, Math.min(1, value));
}
