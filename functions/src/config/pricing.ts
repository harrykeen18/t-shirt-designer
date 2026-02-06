/**
 * Pricing configuration
 *
 * Business model:
 * Customer pays YOUR price → Stripe processes payment →
 * Firebase Function places order with Teemill at THEIR cost →
 * You keep the margin
 */
export const PRICING = {
  tshirt: {
    // What Teemill charges you (approximate, varies by product)
    teemillCost: 15.00,

    // What customer pays you
    yourPrice: 27.00,

    // Your profit margin
    get margin(): number {
      return this.yourPrice - this.teemillCost;
    }
  },

  // Default currency
  currency: 'usd',

  // Stripe takes ~2.9% + $0.30 per transaction
  get stripeFee(): number {
    return this.tshirt.yourPrice * 0.029 + 0.30;
  },

  // Actual profit after Stripe fees
  get netProfit(): number {
    return this.tshirt.margin - this.stripeFee;
  }
};

// Teemill product codes
export const TEEMILL_PRODUCTS = {
  tshirt: {
    white: 'RNA1',
    black: 'RNA1-BLK',
    navy: 'RNA1-NVY',
    charcoal: 'RNA1-CHR',
    red: 'RNA1-RED',
  }
};

// Map color index to Teemill product code
export function getTeemillProductCode(colorIndex: number): string {
  const codes = Object.values(TEEMILL_PRODUCTS.tshirt);
  return codes[colorIndex] || codes[0];
}
