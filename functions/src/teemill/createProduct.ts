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

      // Prepare the base64 image with data URI prefix
      const imageDataUri = data.imageBase64.startsWith('data:')
        ? data.imageBase64
        : `data:image/png;base64,${data.imageBase64}`;

      // Extract raw base64 (without data URI prefix) for Storage
      const rawBase64 = data.imageBase64.startsWith('data:')
        ? data.imageBase64.split(',')[1]
        : data.imageBase64;

      const bucket = admin.storage().bucket();
      const imageBuffer = Buffer.from(rawBase64, 'base64');
      const file = bucket.file(`designs/${referenceId}.png`);
      const storageUrl = `https://storage.googleapis.com/${bucket.name}/designs/${referenceId}.png`;

      // Do Teemill API call, Storage save, and Firestore save in parallel
      const [result] = await Promise.all([
        teemillClient.createProduct({
          image_url: imageDataUri,
          item_code: 'RNA1',  // Men's Basic T-shirt
          colours: color,
          name: data.productName || 'Custom Pixel Art T-Shirt',
          description: 'A unique pixel art design, printed sustainably on organic cotton.',
          cross_sell: false,  // Don't show other products
        }),
        file.save(imageBuffer, {
          metadata: {
            contentType: 'image/png',
            metadata: {
              referenceId,
              tshirtColor: color,
            },
          },
        }).then(() => {
          functions.logger.info('Saved design to Storage', { referenceId });
          return file.makePublic();
        }),
        admin.firestore().collection('designs').doc(referenceId).set({
          referenceId,
          teemillProductUrl: '', // Will be updated after Teemill call
          teemillProductId: '',
          tshirtColorIndex: data.tshirtColorIndex,
          tshirtColor: color,
          imageUrl: storageUrl,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        }),
      ]);

      // Update Firestore with Teemill product details
      await admin.firestore().collection('designs').doc(referenceId).update({
        teemillProductUrl: result.url,
        teemillProductId: result.id,
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
