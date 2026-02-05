import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../canvas/presentation/providers/canvas_provider.dart';
import '../../data/repositories/order_repository.dart';
import '../../../../core/utils/web_redirect.dart'
    if (dart.library.html) '../../../../core/utils/web_redirect_web.dart';

/// Checkout state
enum CheckoutStatus {
  idle,
  creatingProduct,
  redirecting,
  error,
}

class CheckoutState {
  final CheckoutStatus status;
  final String? errorMessage;
  final String? checkoutUrl;

  const CheckoutState({
    required this.status,
    this.errorMessage,
    this.checkoutUrl,
  });

  factory CheckoutState.initial() {
    return const CheckoutState(status: CheckoutStatus.idle);
  }

  CheckoutState copyWith({
    CheckoutStatus? status,
    String? errorMessage,
    String? checkoutUrl,
  }) {
    return CheckoutState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      checkoutUrl: checkoutUrl ?? this.checkoutUrl,
    );
  }

  bool get isLoading =>
      status == CheckoutStatus.creatingProduct ||
      status == CheckoutStatus.redirecting;

  String get statusMessage {
    switch (status) {
      case CheckoutStatus.creatingProduct:
        return 'Creating your product...';
      case CheckoutStatus.redirecting:
        return 'Redirecting to checkout...';
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

  /// Process the checkout - creates a Teemill product and redirects to checkout
  Future<void> processCheckout() async {
    try {
      state = state.copyWith(status: CheckoutStatus.creatingProduct);

      final canvasState = _ref.read(canvasProvider);

      // Create product on Teemill
      final result = await _orderRepository.createTeemillProduct(
        pixels: canvasState.pixels,
        tshirtColorIndex: canvasState.selectedTshirtColorIndex,
        backgroundColor: canvasState.backgroundColor,
      );

      final checkoutUrl = result['checkoutUrl'] as String?;
      if (checkoutUrl == null) {
        throw Exception('No checkout URL returned');
      }

      state = state.copyWith(
        status: CheckoutStatus.redirecting,
        checkoutUrl: checkoutUrl,
      );

      // Open the Teemill checkout URL
      if (kIsWeb) {
        // On web, redirect in same tab (avoids popup blocker)
        redirectToUrl(checkoutUrl);
      } else {
        // On mobile, open in browser
        final uri = Uri.parse(checkoutUrl);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        // Reset state after redirect
        state = CheckoutState.initial();
      }
    } catch (e) {
      state = state.copyWith(
        status: CheckoutStatus.error,
        errorMessage: e.toString(),
      );
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
