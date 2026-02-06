import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'consent_service.dart';
import 'analytics_service.dart';
import 'web_pixel_manager.dart'
    if (dart.library.html) 'web_pixel_manager_web.dart';

/// Provider for SharedPreferences (must be overridden in main)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Not initialized');
});

/// Provider for ConsentService
final consentServiceProvider = Provider<ConsentService>((ref) {
  return ConsentService(ref.watch(sharedPreferencesProvider));
});

/// Provider for FirebaseAnalytics
final firebaseAnalyticsProvider = Provider<FirebaseAnalytics>((ref) {
  return FirebaseAnalytics.instance;
});

/// Provider for AnalyticsService
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(
    ref.watch(firebaseAnalyticsProvider),
    ref.watch(consentServiceProvider),
  );
});

/// Provider for WebPixelManager
final webPixelManagerProvider = Provider<WebPixelManager>((ref) {
  return WebPixelManager();
});
