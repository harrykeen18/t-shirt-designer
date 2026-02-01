import * as functions from 'firebase-functions';

const TEEMILL_API_BASE = 'https://teemill.com/omnis/v3';

// Get API key from environment variables
const TEEMILL_API_KEY = process.env.TEEMILL_API_KEY || '';

interface TeemillApiResponse {
  success: boolean;
  order_id?: string;
  tracking_url?: string;
  error?: string;
  message?: string;
}

/**
 * Teemill API client for placing orders
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
   * Place an order with Teemill
   */
  async placeOrder(payload: {
    image_url: string;
    item_code: string;
    name: string;
    address: string;
    address2?: string;
    city: string;
    region?: string;
    postcode: string;
    country: string;
    quantity?: number;
  }): Promise<TeemillApiResponse> {
    if (!this.apiKey) {
      throw new Error('Teemill API key not configured');
    }

    const response = await fetch(`${TEEMILL_API_BASE}/order`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${this.apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        image_url: payload.image_url,
        item_code: payload.item_code,
        quantity: payload.quantity || 1,
        customer: {
          name: payload.name,
          address: payload.address,
          address2: payload.address2 || '',
          city: payload.city,
          region: payload.region || '',
          postcode: payload.postcode,
          country: payload.country,
        },
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

    const data = await response.json() as TeemillApiResponse;

    if (!data.success) {
      throw new Error(`Teemill order failed: ${data.error || data.message || 'Unknown error'}`);
    }

    return data;
  }

  /**
   * Get order status (if Teemill supports this endpoint)
   */
  async getOrderStatus(orderId: string): Promise<TeemillApiResponse> {
    if (!this.apiKey) {
      throw new Error('Teemill API key not configured');
    }

    const response = await fetch(`${TEEMILL_API_BASE}/order/${orderId}`, {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${this.apiKey}`,
        'Content-Type': 'application/json',
      },
    });

    if (!response.ok) {
      throw new Error(`Failed to get order status: ${response.status}`);
    }

    return response.json() as Promise<TeemillApiResponse>;
  }
}

// Export singleton instance
export const teemillClient = new TeemillClient();
