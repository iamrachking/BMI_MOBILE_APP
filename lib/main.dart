import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ai4bmi/core/theme/app_theme.dart';
import 'package:ai4bmi/routes/app_pages.dart';
import 'package:ai4bmi/routes/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'BMI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      getPages: AppPages.routes,
      initialRoute: AppRoutes.splash,
    );
  }
}
