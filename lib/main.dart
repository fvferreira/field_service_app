import 'package:field_service_app/core/app_theme.dart';
import 'package:field_service_app/screens/splash/splash_screen.dart';
import 'package:field_service_app/services/token_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:field_service_app/providers/auth_provider.dart';
import 'package:field_service_app/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:field_service_app/providers/work_order_provider.dart';
import 'package:field_service_app/services/work_order_service.dart';

void main() {
  final tokenStorageService = TokenStorageService(const FlutterSecureStorage());
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthService(), tokenStorageService),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              WorkOrderProvider(WorkOrderService(tokenStorageService)),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Field Service',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
