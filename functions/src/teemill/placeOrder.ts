import * as functions from 'firebase-functions';
import { teemillClient } from './client';
import { getTeemillProductCode } from '../config/pricing';

interface PlaceOrderParams {
  imageUrl: string;
  tshirtColorIndex: number;
  customer: {
    name: string;
    address: string;
    address2?: string;
    city: string;
    state: string;
    postcode: string;
    country: string;
  };
}

interface PlaceOrderResult {
  success: boolean;
  orderId?: string;
  trackingUrl?: string;
  error?: string;
}

/**
 * Place an order with Teemill fulfillment
 *
 * This is called after successful payment to initiate printing and shipping
 */
export async function placeTeemillOrder(params: PlaceOrderParams): Promise<PlaceOrderResult> {
  const { imageUrl, tshirtColorIndex, customer } = params;

  functions.logger.info('Placing Teemill order', {
    imageUrl,
    tshirtColorIndex,
    customerName: customer.name,
    customerCountry: customer.country,
  });

  try {
    // Get the correct Teemill product code for the selected color
    const itemCode = getTeemillProductCode(tshirtColorIndex);

    const response = await teemillClient.placeOrder({
      image_url: imageUrl,
      item_code: itemCode,
      name: customer.name,
      address: customer.address,
      address2: customer.address2,
      city: customer.city,
      region: customer.state,
      postcode: customer.postcode,
      country: customer.country,
    });

    functions.logger.info('Teemill order placed successfully', {
      orderId: response.order_id,
    });

    return {
      success: true,
      orderId: response.order_id,
      trackingUrl: response.tracking_url,
    };
  } catch (error) {
    functions.logger.error('Failed to place Teemill order', { error });

    return {
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error',
    };
  }
}
