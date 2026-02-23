import 'package:get/get.dart';

import 'package:ai4bmi/features/auth/login_page.dart';
import 'package:ai4bmi/features/auth/register_page.dart';
import 'package:ai4bmi/features/home/home_placeholder_page.dart';
import 'package:ai4bmi/features/onboarding/onboarding_page.dart';
import 'package:ai4bmi/features/splash/splash_page.dart';
import 'package:ai4bmi/routes/app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(name: AppRoutes.splash, page: () => const SplashPage()),
    GetPage(name: AppRoutes.onboarding, page: () => const OnboardingPage()),
    GetPage(name: AppRoutes.login, page: () => const LoginPage()),
    GetPage(name: AppRoutes.register, page: () => const RegisterPage()),
    GetPage(name: AppRoutes.home, page: () => const HomePlaceholderPage()),
  ];
}
