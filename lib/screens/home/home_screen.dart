import 'package:field_service_app/providers/auth_provider.dart';
import 'package:field_service_app/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:field_service_app/providers/work_order_provider.dart';
import 'package:field_service_app/screens/work_order/work_order_detail_screen.dart';
import 'package:field_service_app/screens/inspection/inspection_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkOrderProvider>().loadWorkOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final workOrderProvider = context.watch<WorkOrderProvider>();
    final user = authProvider.user;

    Widget body;
    if (workOrderProvider.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (workOrderProvider.errorMessage != null) {
      body = Center(child: Text(workOrderProvider.errorMessage!));
    } else if (workOrderProvider.workOrders.isEmpty) {
      body = const Center(child: Text('Nenhuma ordem de serviço encontrada'));
    } else {
      body = RefreshIndicator(
        onRefresh: () {
          return workOrderProvider.loadWorkOrders();
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: workOrderProvider.workOrders.length,
          itemBuilder: (context, index) {
            final workOrder = workOrderProvider.workOrders[index];
            return Card(
              child: ListTile(
                title: Text(workOrder.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(workOrder.code),
                    Text(workOrder.address),
                    Text('Status: ${workOrder.status}'),
                    Text('Prioridade: ${workOrder.priority}'),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          WorkOrderDetailScreen(workOrder: workOrder),
                    ),
                  );
                },
              ),
            );
          },
        ),
      );
    }

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

              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Histórico de inspeções'),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InspectionHistoryScreen(),
                    ),
                  );
                },
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
      body: body,
    );
  }
}
