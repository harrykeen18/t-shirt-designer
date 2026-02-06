import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Privacy Policy screen
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'getintouch@pixel-print.com',
      queryParameters: {
        'subject': 'Privacy Policy Inquiry',
      },
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _heading('Privacy Policy'),
              _subheading('Last updated: February 2026'),
              const SizedBox(height: 24),
              _sectionHeading('1. Overview'),
              _bodyText(
                'PixelPrint ("we", "us", "our", or "Company") operates the PixelPrint website and mobile application (collectively, the "Service"). '
                'This Privacy Policy explains how we collect, use, and protect your information when you use our Service.',
              ),
              const SizedBox(height: 20),
              _sectionHeading('2. What Information We Collect'),
              _subSectionHeading('Analytics Data'),
              _bodyText(
                'We use Firebase Analytics to collect information about how you interact with our Service, including:\n'
                '• App launches and screen views\n'
                '• Button clicks and user actions\n'
                '• Checkout flow interactions\n'
                '• Error events',
              ),
              const SizedBox(height: 12),
              _subSectionHeading('Web Tracking Pixels'),
              _bodyText(
                'On our website, we use tracking pixels from:\n'
                '• Meta (Facebook/Instagram) for retargeting\n'
                '• Google Ads for conversion tracking\n\n'
                'These are only activated after you accept analytics cookies.',
              ),
              const SizedBox(height: 12),
              _subSectionHeading('Device Information'),
              _bodyText(
                'Analytics may automatically collect information about your device, such as:\n'
                '• Device type and operating system\n'
                '• Browser type\n'
                '• Approximate location (country/region)',
              ),
              const SizedBox(height: 20),
              _sectionHeading('3. Your Consent'),
              _bodyText(
                'We only collect analytics data after you explicitly accept our consent banner. '
                'If you decline, no analytics or tracking pixels will be activated. '
                'You can change your preferences at any time by clearing your browser cookies or app data.',
              ),
              const SizedBox(height: 20),
              _sectionHeading('4. How We Use Your Information'),
              _bodyText(
                '• Improve our Service and user experience\n'
                '• Understand how users interact with our app\n'
                '• Optimize checkout and product creation flows\n'
                '• Retarget users on social media and search (web only)\n'
                '• Analyze usage patterns and fix errors',
              ),
              const SizedBox(height: 20),
              _sectionHeading('5. Data Retention'),
              _bodyText(
                'Firebase Analytics retains data for 14 months by default. '
                'Tracking pixel data is retained according to Meta and Google policies. '
                'You can request deletion of your data at any time.',
              ),
              const SizedBox(height: 20),
              _sectionHeading('6. Third-Party Service Providers'),
              _bodyText(
                'We share data with:\n'
                '• Google (Firebase Analytics, Google Ads)\n'
                '• Meta (Meta Pixel for retargeting)\n\n'
                'These providers act as data processors and maintain their own privacy policies.',
              ),
              const SizedBox(height: 20),
              _sectionHeading('7. Your Rights (GDPR)'),
              _bodyText(
                'If you are in the EU or other regulated region, you have the right to:\n'
                '• Access your data\n'
                '• Request deletion\n'
                '• Object to processing\n'
                '• Data portability\n\n'
                'To exercise these rights, clear your consent preferences and decline analytics.',
              ),
              const SizedBox(height: 20),
              _sectionHeading('8. Security'),
              _bodyText(
                'We take reasonable measures to protect your information. '
                'However, no method of transmission over the internet is 100% secure.',
              ),
              const SizedBox(height: 20),
              _sectionHeading('9. Changes to This Policy'),
              _bodyText(
                'We may update this privacy policy to reflect changes in our practices. '
                'We will notify you of significant changes by updating the "Last updated" date.',
              ),
              const SizedBox(height: 20),
              _sectionHeading('10. Contact Us'),
              _bodyText(
                'If you have questions about this privacy policy, our data practices, '
                'or to exercise your GDPR rights, please contact us at:',
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _sendEmail,
                child: Text(
                  'getintouch@pixel-print.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heading(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _subheading(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey.shade600,
      ),
    );
  }

  Widget _sectionHeading(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _subSectionHeading(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _bodyText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        height: 1.6,
      ),
    );
  }
}
