import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import Stripe from 'stripe';
import { placeTeemillOrder } from '../teemill/placeOrder';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY || '', {
  apiVersion: '2023-10-16',
});

const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET || '';

/**
 * Stripe webhook handler for payment events
 *
 * Handles payment_intent.succeeded to trigger order fulfillment
 */
export const stripeWebhook = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'POST') {
    res.status(405).send('Method Not Allowed');
    return;
  }

  const sig = req.headers['stripe-signature'];

  if (!sig) {
    res.status(400).send('Missing stripe-signature header');
    return;
  }

  let event: Stripe.Event;

  try {
    event = stripe.webhooks.constructEvent(
      req.rawBody,
      sig,
      webhookSecret
    );
  } catch (err) {
    functions.logger.error('Webhook signature verification failed', err);
    res.status(400).send('Webhook signature verification failed');
    return;
  }

  // Handle the event
  switch (event.type) {
    case 'payment_intent.succeeded':
      await handlePaymentSucceeded(event.data.object as Stripe.PaymentIntent);
      break;

    case 'payment_intent.payment_failed':
      await handlePaymentFailed(event.data.object as Stripe.PaymentIntent);
      break;

    default:
      functions.logger.info(`Unhandled event type: ${event.type}`);
  }

  res.status(200).json({ received: true });
});

/**
 * Handle successful payment - trigger order fulfillment
 */
async function handlePaymentSucceeded(paymentIntent: Stripe.PaymentIntent): Promise<void> {
  const orderId = paymentIntent.metadata.orderId;

  if (!orderId) {
    functions.logger.error('Payment intent missing orderId in metadata');
    return;
  }

  functions.logger.info('Payment succeeded', { orderId, paymentIntentId: paymentIntent.id });

  const db = admin.firestore();
  const orderRef = db.collection('orders').doc(orderId);
  const orderDoc = await orderRef.get();

  if (!orderDoc.exists) {
    functions.logger.error('Order not found', { orderId });
    return;
  }

  const orderData = orderDoc.data()!;

  try {
    // Update order status
    await orderRef.update({
      status: 'payment_received',
      paidAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Place order with Teemill
    const teemillResult = await placeTeemillOrder({
      imageUrl: orderData.designUrl,
      tshirtColorIndex: orderData.tshirtColorIndex,
      customer: {
        name: orderData.shippingAddress.name,
        address: orderData.shippingAddress.line1,
        address2: orderData.shippingAddress.line2 || '',
        city: orderData.shippingAddress.city,
        state: orderData.shippingAddress.state,
        postcode: orderData.shippingAddress.postcode,
        country: orderData.shippingAddress.country,
      },
    });

    // Update order with Teemill reference
    await orderRef.update({
      status: 'order_placed',
      teemillOrderId: teemillResult.orderId,
      teemillResponse: teemillResult,
      fulfilledAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    functions.logger.info('Order placed with Teemill', {
      orderId,
      teemillOrderId: teemillResult.orderId,
    });

  } catch (error) {
    functions.logger.error('Failed to place Teemill order', { orderId, error });

    // Update order status to indicate fulfillment issue
    await orderRef.update({
      status: 'fulfillment_error',
      fulfillmentError: String(error),
    });
  }
}

/**
 * Handle failed payment
 */
async function handlePaymentFailed(paymentIntent: Stripe.PaymentIntent): Promise<void> {
  const orderId = paymentIntent.metadata.orderId;

  if (!orderId) {
    return;
  }

  functions.logger.info('Payment failed', { orderId, paymentIntentId: paymentIntent.id });

  const db = admin.firestore();
  await db.collection('orders').doc(orderId).update({
    status: 'payment_failed',
    failedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}
