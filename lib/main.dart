import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ai4bmi/core/app_links_listener.dart';
import 'package:ai4bmi/core/theme/app_theme.dart';
import 'package:ai4bmi/features/auth/pending_reset_link.dart';
import 'package:ai4bmi/routes/app_pages.dart';
import 'package:ai4bmi/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.delayed(const Duration(milliseconds: 400));
  try {
    final uri = await AppLinks().getInitialLink();
    if (uri != null) PendingResetLink.trySetFromUri(uri);
  } catch (_) {}
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    AppLinksListener.start();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BMI SHOP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      getPages: AppPages.routes,
      initialRoute: AppRoutes.splash,
    );
  }
}
