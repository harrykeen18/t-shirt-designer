import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../core/utils/image_utils.dart';

/// Shipping address model
class ShippingAddress {
  final String name;
  final String line1;
  final String line2;
  final String city;
  final String state;
  final String postcode;
  final String country;

  const ShippingAddress({
    required this.name,
    required this.line1,
    this.line2 = '',
    required this.city,
    required this.state,
    required this.postcode,
    required this.country,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'line1': line1,
      'line2': line2,
      'city': city,
      'state': state,
      'postcode': postcode,
      'country': country,
    };
  }
}

/// Order model
class Order {
  final String id;
  final String designUrl;
  final ShippingAddress shippingAddress;
  final int tshirtColorIndex;
  final int amountCents;
  final String currency;
  final String status;
  final DateTime createdAt;
  final String? teemillOrderId;

  const Order({
    required this.id,
    required this.designUrl,
    required this.shippingAddress,
    required this.tshirtColorIndex,
    required this.amountCents,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.teemillOrderId,
  });
}

/// Repository for order operations (stub implementation - Firebase not yet configured)
class OrderRepository {
  OrderRepository();

  /// Upload design image (stub - returns fake URL)
  Future<String> uploadDesign(
    List<List<Color>> pixels,
    String orderId,
  ) async {
    // In production, this uploads to Firebase Storage
    // For now, just generate the PNG data to verify it works
    final Uint8List pngBytes = await ImageUtils.canvasToPng(pixels);
    debugPrint('Generated PNG: ${pngBytes.length} bytes');

    // Return a placeholder URL
    return 'https://storage.example.com/designs/$orderId.png';
  }

  /// Create a Stripe payment intent (stub)
  Future<Map<String, dynamic>> createPaymentIntent({
    required String designUrl,
    required ShippingAddress shippingAddress,
    required int tshirtColorIndex,
    required int amountCents,
    required String currency,
  }) async {
    // In production, this calls the Firebase function
    // For demo, simulate a delay and return mock data
    await Future.delayed(const Duration(seconds: 1));

    final orderId = 'order_${DateTime.now().millisecondsSinceEpoch}';

    return {
      'clientSecret': 'demo_client_secret',
      'orderId': orderId,
    };
  }

  /// Get order by ID (stub)
  Future<Order?> getOrder(String orderId) async {
    return null;
  }

  /// Stream order updates (stub)
  Stream<Order?> watchOrder(String orderId) {
    return Stream.value(null);
  }
}
