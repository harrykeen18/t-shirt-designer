import * as dotenv from 'dotenv';
import * as admin from 'firebase-admin';

// Load environment variables
dotenv.config();

// Initialize Firebase Admin
admin.initializeApp();

// Export Cloud Functions
export { createTeemillProduct } from './teemill/createProduct';
