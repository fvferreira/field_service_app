import 'package:flutter/material.dart';
import 'package:field_service_app/providers/auth_provider.dart';
import 'package:field_service_app/screens/home/home_screen.dart';
import 'package:field_service_app/screens/login/login_screen.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSession();
    });
  }

  Future<void> _checkSession() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.checkSession();
    if (!mounted) {
      return;
    }

    final destination = authProvider.isAuthenticated
        ? const HomeScreen()
        : const LoginScreen();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
