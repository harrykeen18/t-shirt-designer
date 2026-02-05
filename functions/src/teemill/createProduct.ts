import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { teemillClient } from './client';

// Map app color indices to Teemill color names
const COLOR_MAP: Record<number, string> = {
  0: 'White',
  1: 'Black',
  2: 'Navy Blue',
  3: 'Dark Grey',
  4: 'Red',
};

interface CreateTeemillProductData {
  imageBase64: string;  // Base64 encoded PNG image
  tshirtColorIndex: number;
  productName?: string;
}

/**
 * Creates a Teemill product from a custom design.
 *
 * Returns a checkout URL where the customer can purchase the product.
 * Teemill handles payment and fulfillment.
 */
export const createTeemillProduct = functions.https.onCall(
  async (data: CreateTeemillProductData, context) => {
    if (!data.imageBase64) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Missing required field: imageBase64'
      );
    }

    try {
      // Generate a reference ID for tracking
      const referenceId = `design_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

      // Get the color for this design
      const color = COLOR_MAP[data.tshirtColorIndex] ?? 'White';

      // Create product on Teemill
      const result = await teemillClient.createProduct({
        image_url: data.imageBase64.startsWith('data:')
          ? data.imageBase64
          : `data:image/png;base64,${data.imageBase64}`,
        item_code: 'RNA1',  // Men's Basic T-shirt
        colours: color,
        name: data.productName || 'Custom Pixel Art T-Shirt',
        description: 'A unique pixel art design, printed sustainably on organic cotton.',
        cross_sell: false,  // Don't show other products
      });

      // Log the design for our records
      const db = admin.firestore();
      await db.collection('designs').doc(referenceId).set({
        referenceId,
        teemillProductUrl: result.url,
        teemillProductId: result.id,
        tshirtColorIndex: data.tshirtColorIndex,
        tshirtColor: color,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      functions.logger.info('Created Teemill product', {
        referenceId,
        teemillUrl: result.url,
      });

      return {
        checkoutUrl: result.url,
        referenceId,
      };
    } catch (error) {
      functions.logger.error('Error creating Teemill product', error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to create product'
      );
    }
  }
);
