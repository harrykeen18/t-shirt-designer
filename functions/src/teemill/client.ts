import * as functions from 'firebase-functions';

const TEEMILL_API_BASE = 'https://teemill.com/omnis/v3';

// Get API key from environment variables
const TEEMILL_API_KEY = process.env.TEEMILL_API_KEY || '';

interface CreateProductResponse {
  url: string;
  id?: string;
  name?: string;
  price?: string;
  colours?: string;
  image?: string;
}

interface CreateProductPayload {
  image_url: string;
  item_code: string;
  colours?: string;
  price?: string;
  name?: string;
  description?: string;
  cross_sell?: boolean;
}

/**
 * Teemill API client for creating custom products
 */
export class TeemillClient {
  private apiKey: string;

  constructor(apiKey?: string) {
    this.apiKey = apiKey || TEEMILL_API_KEY;

    if (!this.apiKey) {
      functions.logger.warn('Teemill API key not configured');
    }
  }

  /**
   * Create a custom product on Teemill
   *
   * Returns a URL where customers can view and purchase the product.
   * Teemill handles the checkout and fulfillment.
   */
  async createProduct(payload: CreateProductPayload): Promise<CreateProductResponse> {
    if (!this.apiKey) {
      throw new Error('Teemill API key not configured');
    }

    functions.logger.info('Creating Teemill product', {
      item_code: payload.item_code,
      hasImage: !!payload.image_url,
    });

    const response = await fetch(`${TEEMILL_API_BASE}/product/create`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${this.apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        image_url: payload.image_url,
        item_code: payload.item_code,
        colours: payload.colours,
        price: payload.price,
        name: payload.name,
        description: payload.description,
        cross_sell: payload.cross_sell ?? true,
      }),
    });

    if (!response.ok) {
      const errorText = await response.text();
      functions.logger.error('Teemill API error', {
        status: response.status,
        error: errorText,
      });
      throw new Error(`Teemill API error: ${response.status} - ${errorText}`);
    }

    const data = await response.json() as CreateProductResponse;

    if (!data.url) {
      throw new Error('Teemill API did not return a product URL');
    }

    functions.logger.info('Teemill product created', {
      url: data.url,
      id: data.id,
    });

    return data;
  }
}

// Export singleton instance
export const teemillClient = new TeemillClient();
