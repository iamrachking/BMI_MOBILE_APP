import 'package:ai4bmi/features/cart/cart_page.dart';
import 'package:ai4bmi/features/home/product_detail.dart';
import 'package:ai4bmi/features/orders/orders_page.dart';
import 'package:ai4bmi/features/profile/profile.dart';
import 'package:get/get.dart';

import 'package:ai4bmi/features/auth/change_password_page.dart';
import 'package:ai4bmi/features/auth/forgot_password_page.dart';
import 'package:ai4bmi/features/auth/login_page.dart';
import 'package:ai4bmi/features/auth/register_page.dart';
import 'package:ai4bmi/features/auth/reset_password_page.dart';
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
    GetPage(name: AppRoutes.forgotPassword, page: () => const ForgotPasswordPage()),
    GetPage(name: AppRoutes.resetPassword, page: () => const ResetPasswordPage()),
    GetPage(name: AppRoutes.changePassword, page: () => const ChangePasswordPage()),
    GetPage(name: AppRoutes.home, page: () => const HomePlaceholderPage()),
    GetPage(name: AppRoutes.productDetail, page: () => const ProductDetailScreen()),
    GetPage(name: AppRoutes.cart, page: () => const CartScreen()),
    GetPage(name: AppRoutes.orders, page: () => const OrdersScreen()),
    GetPage(name: AppRoutes.profile, page: () => const ProfileScreen()),
  ];
}
