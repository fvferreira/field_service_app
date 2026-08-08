import 'package:field_service_app/services/token_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:field_service_app/providers/auth_provider.dart';
import 'package:field_service_app/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:field_service_app/screens/login/login_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(
        AuthService(),
        TokenStorageService(const FlutterSecureStorage()),
      ),
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
      home: const LoginScreen(),
    );
  }
}
