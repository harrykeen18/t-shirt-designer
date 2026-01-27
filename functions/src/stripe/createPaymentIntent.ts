import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import Stripe from 'stripe';

// Initialize Stripe with secret key from Firebase config
const stripe = new Stripe(functions.config().stripe?.secret_key || process.env.STRIPE_SECRET_KEY || '', {
  apiVersion: '2023-10-16',
});

interface CreatePaymentIntentData {
  designUrl: string;
  shippingAddress: {
    name: string;
    line1: string;
    line2?: string;
    city: string;
    state: string;
    postcode: string;
    country: string;
  };
  tshirtColorIndex: number;
  tshirtColor: string;
  amountCents: number;
  currency: string;
}

/**
 * Creates a Stripe Payment Intent for a t-shirt order
 *
 * Called from the Flutter app when user initiates checkout
 */
export const createPaymentIntent = functions.https.onCall(
  async (data: CreatePaymentIntentData, context) => {
    // Validate request
    if (!data.designUrl || !data.shippingAddress || !data.amountCents) {
      throw new functions.https.HttpsError(
        'invalid-argument',
        'Missing required fields: designUrl, shippingAddress, amountCents'
      );
    }

    try {
      // Generate order ID
      const orderId = `order_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

      // Create payment intent
      const paymentIntent = await stripe.paymentIntents.create({
        amount: data.amountCents,
        currency: data.currency || 'usd',
        automatic_payment_methods: {
          enabled: true,
        },
        metadata: {
          orderId: orderId,
          designUrl: data.designUrl,
          tshirtColorIndex: String(data.tshirtColorIndex),
          tshirtColor: data.tshirtColor,
          customerName: data.shippingAddress.name,
          customerCity: data.shippingAddress.city,
          customerCountry: data.shippingAddress.country,
        },
        shipping: {
          name: data.shippingAddress.name,
          address: {
            line1: data.shippingAddress.line1,
            line2: data.shippingAddress.line2 || undefined,
            city: data.shippingAddress.city,
            state: data.shippingAddress.state,
            postal_code: data.shippingAddress.postcode,
            country: data.shippingAddress.country,
          },
        },
      });

      // Create pending order in Firestore
      const db = admin.firestore();
      await db.collection('orders').doc(orderId).set({
        orderId: orderId,
        designUrl: data.designUrl,
        shippingAddress: data.shippingAddress,
        tshirtColorIndex: data.tshirtColorIndex,
        tshirtColor: data.tshirtColor,
        amountCents: data.amountCents,
        currency: data.currency || 'usd',
        stripePaymentIntentId: paymentIntent.id,
        status: 'pending_payment',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      functions.logger.info('Created payment intent', {
        orderId,
        paymentIntentId: paymentIntent.id,
      });

      return {
        clientSecret: paymentIntent.client_secret,
        orderId: orderId,
      };
    } catch (error) {
      functions.logger.error('Error creating payment intent', error);
      throw new functions.https.HttpsError(
        'internal',
        'Failed to create payment intent'
      );
    }
  }
);
