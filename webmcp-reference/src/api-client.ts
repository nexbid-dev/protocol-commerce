// Fetch wrapper for WebMCP tool backends.
// All calls go to same-origin Vercel API routes (no CORS issues).

const API_BASE = '/api';

export interface SearchParams {
  query: string;
  geo?: string;
  category?: string;
  brand?: string;
  budget_min_cents?: number;
  budget_max_cents?: number;
  limit?: number;
  intent?: string;
}

export interface ProductResult {
  id: string;
  title: string;
  description?: string;
  price_cents: number;
  currency: string;
  brand?: string;
  category?: string;
  availability: string;
  url: string;
  image_url?: string;
  score?: number;
}

export interface SearchResponse {
  products: ProductResult[];
  totalMatches: number;
  latencyMs: number;
}

export interface CategoryResult {
  category: string;
  product_count: number;
}

export interface PurchaseIntentResponse {
  intent_id: string;
  checkout_url: string;
  mode: string;
  product_title: string;
  price: string;
}

export interface OrderStatusResponse {
  intent_id: string;
  status: string;
  product_title: string;
  price: string;
  checkout_url?: string;
  created_at: string;
  expires_at?: string;
}

/** Search products via /api/products */
export async function searchProducts(params: SearchParams): Promise<SearchResponse> {
  const url = new URL(`${API_BASE}/products`, window.location.origin);
  url.searchParams.set('q', params.query);
  if (params.geo) url.searchParams.set('geo', params.geo);
  if (params.category) url.searchParams.set('category', params.category);
  if (params.brand) url.searchParams.set('brand', params.brand);
  if (params.budget_min_cents) url.searchParams.set('budget_min_cents', String(params.budget_min_cents));
  if (params.budget_max_cents) url.searchParams.set('budget_max_cents', String(params.budget_max_cents));
  if (params.limit) url.searchParams.set('limit', String(params.limit));
  if (params.intent) url.searchParams.set('intent', params.intent);

  const res = await fetch(url.toString());
  if (!res.ok) throw new Error(`Search failed: ${res.status}`);
  return res.json();
}

/** Get product details via /api/products/[id] */
export async function getProductById(productId: string): Promise<ProductResult> {
  const res = await fetch(`${API_BASE}/products/${productId}`);
  if (!res.ok) throw new Error(`Product not found: ${res.status}`);
  return res.json();
}

/** List categories via /api/categories */
export async function listCategories(geo?: string): Promise<CategoryResult[]> {
  const url = new URL(`${API_BASE}/categories`, window.location.origin);
  if (geo) url.searchParams.set('geo', geo);
  const res = await fetch(url.toString());
  if (!res.ok) throw new Error(`Categories failed: ${res.status}`);
  const data = await res.json();
  return data.categories;
}

/** Create purchase intent via /api/purchase/intent */
export async function createPurchaseIntent(
  productId: string,
  quantity: number = 1,
): Promise<PurchaseIntentResponse> {
  const res = await fetch(`${API_BASE}/purchase/intent`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ product_id: productId, quantity }),
  });
  if (!res.ok) throw new Error(`Purchase failed: ${res.status}`);
  return res.json();
}

/** Check order status via /api/purchase/status */
export async function getOrderStatus(intentId: string): Promise<OrderStatusResponse> {
  const url = new URL(`${API_BASE}/purchase/status`, window.location.origin);
  url.searchParams.set('id', intentId);
  const res = await fetch(url.toString());
  if (!res.ok) throw new Error(`Status check failed: ${res.status}`);
  return res.json();
}
