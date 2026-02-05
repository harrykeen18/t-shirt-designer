/// Pricing configuration for t-shirts
///
/// Note: Actual price is set by Teemill. This is for display purposes only.
class Pricing {
  Pricing._();

  /// Display price (approximate - actual price shown at Teemill checkout)
  static const double tshirtPrice = 25.00;

  /// Currency
  static const String currency = 'GBP';

  /// Shipping info
  static const String shippingInfo = 'Free worldwide shipping';

  /// Format price for display
  static String formatPrice(double price) {
    return '£${price.toStringAsFixed(2)}';
  }
}
