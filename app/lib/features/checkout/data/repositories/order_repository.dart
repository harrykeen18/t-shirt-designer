import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/image_utils.dart';

/// Repository for order operations
class OrderRepository {
  final FirebaseFunctions _functions;

  OrderRepository({
    FirebaseFunctions? functions,
  }) : _functions = functions ?? FirebaseFunctions.instance;

  /// Create a Teemill product from the design and get checkout URL.
  ///
  /// Converts the pixel canvas to a PNG, sends it to Teemill,
  /// and returns a URL where the customer can complete their purchase.
  Future<Map<String, dynamic>> createTeemillProduct({
    required List<List<Color>> pixels,
    required int tshirtColorIndex,
    required Color backgroundColor,
    String? productName,
  }) async {
    // Convert canvas to PNG bytes with background color
    final Uint8List pngBytes = await ImageUtils.canvasToPng(
      pixels,
      backgroundColor: backgroundColor,
    );

    // Base64 encode for the API
    final String base64Image = base64Encode(pngBytes);

    // Call the Cloud Function
    final callable = _functions.httpsCallable('createTeemillProduct');
    final result = await callable.call<Map<String, dynamic>>({
      'imageBase64': base64Image,
      'tshirtColorIndex': tshirtColorIndex,
      if (productName != null) 'productName': productName,
    });

    return Map<String, dynamic>.from(result.data);
  }
}
