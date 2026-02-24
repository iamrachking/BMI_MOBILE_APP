import 'package:flutter/material.dart';
import 'package:ai4bmi/core/theme/app_theme.dart';

/// Accent décoratif pour les pages auth. Position et style différents par page.
enum AuthAccentPosition {
  topRight,
  topLeft,
  bottomLeft,
  bottomRight,
  centerRight,
}

class AuthAccent extends StatelessWidget {
  final AuthAccentPosition position;

  const AuthAccent({super.key, required this.position});

  @override
  Widget build(BuildContext context) {
    switch (position) {
      case AuthAccentPosition.topRight:
        return _build(top: 0, right: 0, angle: 0.4, width: 120, height: 200);
      case AuthAccentPosition.topLeft:
        return _build(top: 0, left: 0, angle: -0.35, width: 100, height: 180);
      case AuthAccentPosition.bottomLeft:
        return _build(bottom: 0, left: 0, angle: 0.5, width: 140, height: 160);
      case AuthAccentPosition.bottomRight:
        return _build(
          bottom: 0,
          right: 0,
          angle: -0.45,
          width: 110,
          height: 190,
        );
      case AuthAccentPosition.centerRight:
        return _build(
          top: 0.25 * (MediaQuery.of(context).size.height),
          right: 0,
          angle: 0.2,
          width: 90,
          height: 140,
        );
    }
  }

  Widget _build({
    double? top,
    double? left,
    double? right,
    double? bottom,
    required double angle,
    required double width,
    required double height,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Transform.rotate(
        angle: angle,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                AppTheme.primary.withValues(alpha: 0.15),
                AppTheme.primary.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }
}
