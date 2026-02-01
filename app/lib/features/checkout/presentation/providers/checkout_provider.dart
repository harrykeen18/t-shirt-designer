import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../../../core/constants/pricing.dart';
import '../../../canvas/presentation/providers/canvas_provider.dart';
import '../../data/repositories/order_repository.dart';

/// Checkout state
enum CheckoutStatus {
  idle,
  uploadingDesign,
  creatingPayment,
  processingPayment,
  success,
  error,
}

class CheckoutState {
  final CheckoutStatus status;
  final String? errorMessage;
  final String? orderId;
  final ShippingAddress? shippingAddress;

  const CheckoutState({
    required this.status,
    this.errorMessage,
    this.orderId,
    this.shippingAddress,
  });

  factory CheckoutState.initial() {
    return const CheckoutState(status: CheckoutStatus.idle);
  }

  CheckoutState copyWith({
    CheckoutStatus? status,
    String? errorMessage,
    String? orderId,
    ShippingAddress? shippingAddress,
  }) {
    return CheckoutState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      orderId: orderId ?? this.orderId,
      shippingAddress: shippingAddress ?? this.shippingAddress,
    );
  }

  bool get isLoading =>
      status == CheckoutStatus.uploadingDesign ||
      status == CheckoutStatus.creatingPayment ||
      status == CheckoutStatus.processingPayment;

  String get statusMessage {
    switch (status) {
      case CheckoutStatus.uploadingDesign:
        return 'Uploading your design...';
      case CheckoutStatus.creatingPayment:
        return 'Setting up payment...';
      case CheckoutStatus.processingPayment:
        return 'Processing payment...';
      case CheckoutStatus.success:
        return 'Order placed successfully!';
      case CheckoutStatus.error:
        return errorMessage ?? 'An error occurred';
      default:
        return '';
    }
  }
}

/// Checkout state notifier
class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final Ref _ref;
  final OrderRepository _orderRepository;

  CheckoutNotifier(this._ref, this._orderRepository)
      : super(CheckoutState.initial());

  /// Update shipping address
  void setShippingAddress(ShippingAddress address) {
    state = state.copyWith(shippingAddress: address);
  }

  /// Process the checkout
  Future<bool> processCheckout() async {
    if (state.shippingAddress == null) {
      state = state.copyWith(
        status: CheckoutStatus.error,
        errorMessage: 'Please enter a shipping address',
      );
      return false;
    }

    try {
      // 1. Upload design
      state = state.copyWith(status: CheckoutStatus.uploadingDesign);

      final canvasState = _ref.read(canvasProvider);
      final orderId = DateTime.now().millisecondsSinceEpoch.toString();

      final designUrl = await _orderRepository.uploadDesign(
        canvasState.pixels,
        orderId,
      );

      // 2. Create payment intent
      state = state.copyWith(status: CheckoutStatus.creatingPayment);

      final paymentResult = await _orderRepository.createPaymentIntent(
        designUrl: designUrl,
        shippingAddress: state.shippingAddress!,
        tshirtColorIndex: canvasState.selectedTshirtColorIndex,
        amountCents: Pricing.tshirtPriceCents,
        currency: Pricing.currency.toLowerCase(),
      );

      final clientSecret = paymentResult['clientSecret'] as String?;
      final returnedOrderId = paymentResult['orderId'] as String?;

      if (clientSecret == null) {
        throw Exception('Failed to create payment intent');
      }

      // 3. Present payment sheet
      state = state.copyWith(status: CheckoutStatus.processingPayment);

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'T-Shirt Print',
          style: ThemeMode.system,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      // 4. Success!
      state = state.copyWith(
        status: CheckoutStatus.success,
        orderId: returnedOrderId ?? orderId,
      );

      return true;
    } on StripeException catch (e) {
      // User cancelled or payment failed
      if (e.error.code == FailureCode.Canceled) {
        state = state.copyWith(status: CheckoutStatus.idle);
      } else {
        state = state.copyWith(
          status: CheckoutStatus.error,
          errorMessage: e.error.localizedMessage ?? 'Payment failed',
        );
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        status: CheckoutStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Reset checkout state
  void reset() {
    state = CheckoutState.initial();
  }
}

/// Provider for order repository
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository();
});

/// Provider for checkout state
final checkoutProvider =
    StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  final orderRepository = ref.watch(orderRepositoryProvider);
  return CheckoutNotifier(ref, orderRepository);
});
