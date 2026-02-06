import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Footer with privacy policy link (web-only)
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Center(
        child: GestureDetector(
          onTap: () => context.push('/privacy-policy'),
          child: Text(
            'Privacy Policy',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              decoration: TextDecoration.underline,
              decorationColor: Colors.grey.shade500,
            ),
          ),
        ),
      ),
    );
  }
}
