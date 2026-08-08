import 'package:field_service_app/providers/auth_provider.dart';
import 'package:field_service_app/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _formatRole(String? role) {
    if (role == 'field_technician') {
      return 'Técnico de campo';
    }

    if (role == 'admin') {
      return 'Administrador';
    }

    return 'Funcionário';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    return Scaffold(
      appBar: AppBar(title: const Text('Ordens de Serviço')),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(user?.name ?? 'Usuário'),
                accountEmail: Text(user?.email ?? ''),
              ),
              ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: const Text('Função'),
                subtitle: Text(_formatRole(user?.role)),
              ),
              const Spacer(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sair'),
                onTap: () async {
                  await authProvider.logout();
                  if (!context.mounted) {
                    return;
                  }

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: const Center(child: Text('Ordens de Serviço')),
    );
  }
}
