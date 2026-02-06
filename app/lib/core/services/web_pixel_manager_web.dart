import 'dart:html' as html;

/// Web implementation for Meta Pixel and Google Ads tracking
class WebPixelManager {
  /// Enable tracking by granting consent to pixels
  void enableTracking() {
    _executeScript("fbq('consent', 'grant');");
    _executeScript(
      "gtag('consent', 'update', {'ad_storage': 'granted', 'analytics_storage': 'granted'});",
    );
  }

  /// Track page view on Meta Pixel
  void trackPageView() {
    _executeScript("fbq('track', 'PageView');");
  }

  /// Track initiate checkout on Meta Pixel
  void trackInitiateCheckout() {
    _executeScript("fbq('track', 'InitiateCheckout');");
  }

  /// Execute JavaScript by injecting a script tag
  void _executeScript(String code) {
    final script = html.ScriptElement();
    script.text = code;
    html.document.head?.append(script);
    script.remove(); // Remove after execution
  }
}
