import 'package:field_service_app/models/work_order.dart';
import 'package:field_service_app/screens/inspection/inspection_form_screen.dart';
import 'package:flutter/material.dart';

class WorkOrderDetailScreen extends StatelessWidget {
  final WorkOrder workOrder;
  const WorkOrderDetailScreen({super.key, required this.workOrder});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(workOrder.code)),
      body: Padding(
        padding: const EdgeInsetsGeometry.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              workOrder.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(workOrder.description),
            const SizedBox(height: 12),
            Text('Endereço: ${workOrder.address}'),
            Text('Status: ${workOrder.status}'),
            Text('Prioridade: ${workOrder.priority}'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          InspectionFormScreen(workOrder: workOrder),
                    ),
                  );
                },
                child: const Text('Iniciar inspeção'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
