# AdCP Privacy Model

**Version:** 0.1.0

## Core Principle

> Context over identity. Describe the situation, not the person.

AdCP is designed to function with zero knowledge of the end user's identity. All targeting, ranking, and attribution use context signals — never user profiles.

## What Crosses the Protocol Boundary

### Allowed (Context Signals)

| Signal | Example | Purpose |
|--------|---------|---------|
| Search query | "organic olive oil" | Product matching |
| Search intent | `purchase` | Ranking adjustment |
| Geography | `CH` | Availability filtering, geo-targeting |
| Category filter | "Food & Beverages" | Narrowing search scope |
| Brand filter | "Alnatura" | Brand-specific queries |
| Budget range | 1000-5000 cents | Price filtering |
| Currency | `CHF` | Localization |

### Prohibited (User Identifiers)

| Signal | Status | Reason |
|--------|--------|--------|
| User ID | ❌ Prohibited | Creates persistent profile |
| Session ID | ❌ Prohibited | Enables cross-query linking |
| Cookie | ❌ Prohibited | Cross-site tracking |
| Device fingerprint | ❌ Prohibited | Passive identification |
| IP address | ❌ Prohibited | Location + identification |
| Browser fingerprint | ❌ Prohibited | Passive identification |
| Login state | ❌ Prohibited | Identity linkage |
| Purchase history | ❌ Prohibited | Behavioral profiling |
| Demographics | ❌ Prohibited | Group-level targeting |

## Why This Matters

### Regulatory Simplicity

Without personal data in the targeting pipeline, AdCP deployments do not require:

- GDPR consent management for ad targeting (no personal data processed for this purpose)
- Cookie consent banners for the ad system
- Data Processing Agreements between protocol participants for targeting purposes
- Data Protection Impact Assessments for the ad targeting component

Note: Other aspects of a deployment (e.g., user authentication, analytics) may still require privacy compliance. AdCP's privacy model applies specifically to the commerce discovery and attribution layer.

### No Consent Fatigue

Users are not asked to consent to ad tracking because there is no ad tracking. The protocol functions identically for users who would accept tracking and those who would reject it.

### Advertiser Benefit

Context-based targeting often outperforms identity-based targeting in commerce contexts:

- A user searching for "running shoes" on a sports site has clear purchase intent — no profile needed
- Context is real-time and accurate; user profiles decay and become stale
- No wasted spend on users who have already purchased (a common retargeting problem)

## Implementation Requirements

### Server Requirements

AdCP-compliant servers MUST:

1. Not store user-identifying information from protocol messages
2. Not attempt to infer user identity from context signals
3. Not share context signals across different queries for the purpose of building user profiles
4. Use UUID v7 for query identifiers (time-ordered but not user-linked)
5. Log attribution events without user identifiers

### Agent Requirements

AdCP-compatible agents SHOULD:

1. Not include user-identifying information in protocol messages
2. Strip any user context before sending AdCP requests
3. Disclose sponsored results to the user

### Audit Compliance

To verify privacy compliance, operators can audit their AdCP deployment by checking:

1. **Database schemas:** No columns storing user IDs, session IDs, or device fingerprints in ad-related tables
2. **API logs:** No user identifiers in request/response logs
3. **Attribution events:** Only `queryId` (UUID v7), `productId`, `campaignId`, and context fields

The MIT-licensed protocol and reference schemas enable independent auditing.

## Comparison to Other Approaches

| Aspect | Traditional Ad Tech | ACP (OpenAI) | UCP (Google) | AdCP |
|--------|-------------------|-------------|-------------|------|
| Cookies | Yes | Platform-managed | Google-managed | None |
| User Profiles | Yes | ChatGPT user data | Google user data | None |
| Cross-Site Tracking | Yes | Platform scope | Google scope | None |
| Consent Required | Yes (GDPR) | Platform ToS | Google ToS | Not for targeting |
| Targeting Method | Identity + Context | Identity + Context | Identity + Context | Context only |
| Auditable | Rarely | No (proprietary) | No (proprietary) | Yes (MIT) |
