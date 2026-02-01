import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
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

  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Order(
      id: doc.id,
      designUrl: data['designUrl'] ?? '',
      shippingAddress: ShippingAddress(
        name: data['shippingAddress']?['name'] ?? '',
        line1: data['shippingAddress']?['line1'] ?? '',
        line2: data['shippingAddress']?['line2'] ?? '',
        city: data['shippingAddress']?['city'] ?? '',
        state: data['shippingAddress']?['state'] ?? '',
        postcode: data['shippingAddress']?['postcode'] ?? '',
        country: data['shippingAddress']?['country'] ?? '',
      ),
      tshirtColorIndex: data['tshirtColorIndex'] ?? 0,
      amountCents: data['amountCents'] ?? 0,
      currency: data['currency'] ?? 'USD',
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      teemillOrderId: data['teemillOrderId'],
    );
  }
}

/// Repository for order operations
class OrderRepository {
  final FirebaseFunctions _functions;
  final FirebaseStorage _storage;
  final FirebaseFirestore _firestore;

  OrderRepository({
    FirebaseFunctions? functions,
    FirebaseStorage? storage,
    FirebaseFirestore? firestore,
  })  : _functions = functions ?? FirebaseFunctions.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Upload design image to Firebase Storage
  Future<String> uploadDesign(
    List<List<Color>> pixels,
    String orderId,
  ) async {
    // Convert canvas to high-res PNG
    final Uint8List pngBytes = await ImageUtils.canvasToPng(pixels);

    // Upload to Firebase Storage
    final ref = _storage.ref().child('designs/$orderId.png');
    final uploadTask = await ref.putData(
      pngBytes,
      SettableMetadata(contentType: 'image/png'),
    );

    // Return download URL
    return await uploadTask.ref.getDownloadURL();
  }

  /// Create a Stripe payment intent
  Future<Map<String, dynamic>> createPaymentIntent({
    required String designUrl,
    required ShippingAddress shippingAddress,
    required int tshirtColorIndex,
    required int amountCents,
    required String currency,
  }) async {
    final callable = _functions.httpsCallable('createPaymentIntent');
    final result = await callable.call<Map<String, dynamic>>({
      'designUrl': designUrl,
      'shippingAddress': shippingAddress.toMap(),
      'tshirtColorIndex': tshirtColorIndex,
      'tshirtColor': AppColors.tshirtColorNames[tshirtColorIndex],
      'amountCents': amountCents,
      'currency': currency,
    });

    return Map<String, dynamic>.from(result.data);
  }

  /// Get order by ID
  Future<Order?> getOrder(String orderId) async {
    final doc = await _firestore.collection('orders').doc(orderId).get();
    if (!doc.exists) return null;
    return Order.fromFirestore(doc);
  }

  /// Stream order updates
  Stream<Order?> watchOrder(String orderId) {
    return _firestore
        .collection('orders')
        .doc(orderId)
        .snapshots()
        .map((doc) => doc.exists ? Order.fromFirestore(doc) : null);
  }
}
