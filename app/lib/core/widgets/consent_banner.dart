import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:go_router/go_router.dart';
import '../services/providers.dart';

/// GDPR-compliant consent banner widget
class ConsentBanner extends ConsumerStatefulWidget {
  const ConsentBanner({super.key});

  @override
  ConsumerState<ConsentBanner> createState() => _ConsentBannerState();
}

class _ConsentBannerState extends ConsumerState<ConsentBanner> {
  bool _showBanner = false;
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    _checkConsent();
  }

  Future<void> _checkConsent() async {
    final consent = ref.read(consentServiceProvider);
    final hasChoice = await consent.hasUserMadeChoice();
    if (mounted) {
      setState(() => _showBanner = !hasChoice);
    }
  }

  Future<void> _handleAccept() async {
    final consent = ref.read(consentServiceProvider);
    await consent.grantConsent();

    // Enable Firebase Analytics
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

    // Enable web pixels if on web
    if (kIsWeb) {
      ref.read(webPixelManagerProvider).enableTracking();
      ref.read(webPixelManagerProvider).trackPageView();
    }

    if (mounted) {
      setState(() => _showBanner = false);
    }
  }

  Future<void> _handleDecline() async {
    await ref.read(consentServiceProvider).denyConsent();
    if (mounted) {
      setState(() => _showBanner = false);
    }
  }

  void _toggleDetails() {
    setState(() => _showDetails = !_showDetails);
  }

  @override
  Widget build(BuildContext context) {
    if (!_showBanner) return const SizedBox.shrink();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(12),
          color: Colors.grey.shade100,
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'This website uses cookies.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_showDetails) ...[
                  const SizedBox(height: 8),
                  Text(
                    'We use cookies and similar tracking technologies to improve your experience. This includes:',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Firebase Analytics - to understand app usage\n'
                    '• Meta Pixel - for social media advertising\n'
                    '• Google Ads - for conversion tracking',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => context.push('/privacy-policy'),
                    child: Text(
                      'Read our full Privacy Policy',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _showDetails ? _handleDecline : _toggleDetails,
                        child: Text(_showDetails ? 'Decline' : 'Learn more'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleAccept,
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
