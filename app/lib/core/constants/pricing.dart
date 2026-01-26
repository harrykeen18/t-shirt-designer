/// Pricing configuration for t-shirts
class Pricing {
  Pricing._();

  /// The price customers pay (in cents for Stripe)
  static const int tshirtPriceCents = 3500; // $35.00

  /// Display price
  static const double tshirtPrice = 35.00;

  /// Currency
  static const String currency = 'USD';

  /// Shipping (included in price)
  static const double shippingIncluded = 0.00;

  /// Format price for display
  static String formatPrice(double price) {
    return '\$${price.toStringAsFixed(2)}';
  }
}
