# AdCP Scoring Model

**Version:** 0.1.0

## The Formula

AdCP uses a weighted composite score to rank sponsored products in auction results:

```
score = (W_bid × normalized_bid) + (W_relevance × similarity) + (W_quality × quality_signal)
```

### Default Weights

| Weight | Symbol | Default | Range |
|--------|--------|---------|-------|
| Bid weight | W_bid | 0.4 | 0.0 – 1.0 |
| Relevance weight | W_relevance | 0.4 | 0.0 – 1.0 |
| Quality weight | W_quality | 0.2 | 0.0 – 1.0 |

**Constraint:** `W_bid + W_relevance + W_quality = 1.0`

### Component Definitions

#### Normalized Bid

```
normalized_bid = bid_cents / max_bid_in_auction
```

Range: 0.0 to 1.0. The highest bidder gets 1.0. Normalization ensures bid magnitude doesn't dominate the score.

If only one participant: `normalized_bid = 1.0`.

#### Similarity (Relevance)

```
similarity = semantic_match(query, product)
```

Range: 0.0 to 1.0. Measures how well the product matches the agent's query. Implementation-specific — the spec does not mandate a particular similarity algorithm.

**Reference implementation (Nexbid):** PostgreSQL trigram similarity (`pg_trgm`) across title, description, and brand fields. `similarity = GREATEST(sim(title, q), sim(desc, q), sim(brand, q))`.

Implementations MAY use embedding-based similarity, BM25, or other ranking approaches. The protocol requires that the method is documented.

#### Quality Signal

```
quality_signal = campaign_quality_score
```

Range: 0.0 to 1.0. A composite metric reflecting the advertiser's historical performance:

- Click-through rate
- Product data completeness (title, description, image, availability)
- Landing page quality
- Historical relevance scores

Quality scores are maintained by the server and disclosed to the advertiser upon request.

## Score Properties

### Deterministic

Given identical inputs (bid, query, product catalog, quality scores), the formula produces identical output. There is no randomization component.

### Auditable

Any participant can calculate their expected score:
1. Bid is known (they set it)
2. Similarity can be estimated (by testing queries against the search API)
3. Quality score is available on request

### Configurable

Server operators MAY adjust weights. For example, a publisher-focused deployment might increase W_relevance:

```
W_bid = 0.2, W_relevance = 0.6, W_quality = 0.2
```

**Disclosure requirement:** Active weights MUST be available via an `adcp.config` endpoint or documented in the server's API reference. Participants must be able to verify which weights are in effect.

## Organic vs. Sponsored

AdCP distinguishes between organic and sponsored results:

| Aspect | Organic | Sponsored |
|--------|---------|-----------|
| Ranking | Similarity only | Composite score (bid + similarity + quality) |
| Billing | None | Per-click or per-action (configurable) |
| Disclosure | None required | `sponsored: true` MUST be set |
| Position | Ranked by relevance | Merged with organic results by score |

Servers MUST NOT disguise sponsored results as organic. The `sponsored` field is a protocol-level requirement.

## Merge Strategy

When both organic and sponsored results are present, the server merges them by score. A sponsored result with `score = 0.82` ranks between organic results with `similarity = 0.85` and `similarity = 0.80`.

This ensures that highly relevant organic results are not displaced by low-relevance, high-bid sponsored results.

## Anti-Gaming

The quality signal component (W_quality = 0.2) prevents pure bid-based ranking. A high bidder with poor quality scores will be outranked by a moderate bidder with good quality. This incentivizes advertisers to invest in product data quality, not just ad spend.
