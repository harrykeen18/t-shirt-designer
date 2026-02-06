import 'package:firebase_analytics/firebase_analytics.dart';
import 'consent_service.dart';

/// Service to log analytics events with consent checking
class AnalyticsService {
  final FirebaseAnalytics _analytics;
  final ConsentService _consentService;

  AnalyticsService(this._analytics, this._consentService);

  /// Log app opened event
  Future<void> logAppOpened() async {
    await _logEvent('app_opened');
  }

  /// Log screen view event
  Future<void> logScreenView(String screenName) async {
    await _logEvent('screen_view', {
      'screen_name': screenName,
    });
  }

  /// Log order button clicked event
  Future<void> logOrderButtonClicked() async {
    await _logEvent('order_button_clicked');
  }

  /// Log checkout started event
  Future<void> logCheckoutStarted() async {
    await _logEvent('checkout_started');
  }

  /// Log product creation success event
  Future<void> logProductCreationSuccess(String checkoutUrl) async {
    await _logEvent('product_creation_success', {
      'checkout_url': checkoutUrl,
    });
  }

  /// Log redirect to checkout event
  Future<void> logRedirectToCheckout(String checkoutUrl) async {
    await _logEvent('redirect_to_checkout', {
      'checkout_url': checkoutUrl,
    });
  }

  /// Log checkout error event
  Future<void> logCheckoutError(String error) async {
    await _logEvent('checkout_error', {
      'error_message': error,
    });
  }

  /// Internal helper: logs event only if user has given consent
  Future<void> _logEvent(
    String name, [
    Map<String, Object>? params,
  ]) async {
    if (!await _consentService.hasConsent()) {
      return;
    }
    await _analytics.logEvent(name: name, parameters: params);
  }
}
