import * as admin from 'firebase-admin';

// Initialize Firebase Admin
admin.initializeApp();

// Export Cloud Functions
export { createPaymentIntent } from './stripe/createPaymentIntent';
export { stripeWebhook } from './stripe/webhookHandler';
