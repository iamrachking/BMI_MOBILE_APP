import 'package:flutter/material.dart';

import 'package:ai4bmi/core/theme/app_theme.dart';

class SocialButtonsRow extends StatelessWidget {
  const SocialButtonsRow({super.key});

  static const _assets = [
    ('assets/images/logo_applee.jpg', Icons.apple),
    ('assets/images/google_logo.png', Icons.g_mobiledata_outlined),
    ('assets/images/logo_facebookk.png', Icons.facebook),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _assets
          .map((e) => _SocialCircle(assetPath: e.$1, icon: e.$2))
          .toList(),
    );
  }
}

class _SocialCircle extends StatelessWidget {
  final String assetPath;
  final IconData icon;

  const _SocialCircle({required this.assetPath, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 1,
        shadowColor: Colors.black26,
        child: InkWell(
          onTap: () {},
          customBorder: const CircleBorder(),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipOval(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.contain,
                    width: 30,
                    height: 30,
                    errorBuilder: (_, __, ___) => SizedBox(
                      width: 32,
                      height: 32,
                      child: Center(
                        child: Icon(icon, size: 29, color: AppTheme.primary),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
