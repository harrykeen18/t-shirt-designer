import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage user consent for analytics tracking
class ConsentService {
  final SharedPreferences _prefs;
  static const _key = 'analytics_consent';

  ConsentService(this._prefs);

  /// Check if user has granted consent for analytics
  Future<bool> hasConsent() async {
    return _prefs.getBool(_key) ?? false;
  }

  /// Check if user has made a choice (accepted or declined)
  Future<bool> hasUserMadeChoice() async {
    return _prefs.containsKey(_key);
  }

  /// Grant consent for analytics
  Future<void> grantConsent() async {
    await _prefs.setBool(_key, true);
  }

  /// Deny consent for analytics
  Future<void> denyConsent() async {
    await _prefs.setBool(_key, false);
  }
}
