import 'package:field_service_app/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:field_service_app/models/inspection.dart';
import 'dart:io';

class InspectionHistoryScreen extends StatefulWidget {
  const InspectionHistoryScreen({super.key});

  @override
  State<InspectionHistoryScreen> createState() =>
      _InspectionHistoryScreenState();
}

class _InspectionHistoryScreenState extends State<InspectionHistoryScreen> {
  final DatabaseService _databaseService = DatabaseService();

  List<Inspection> _inspections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInspections();
  }

  Future<void> _loadInspections() async {
    final inspections = await _databaseService.getInspections();
    if (!mounted) {
      return;
    }

    setState(() {
      _inspections = inspections;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de inspeções')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _inspections.isEmpty
          ? const Center(child: Text('Nenhuma inspeção encontrada'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _inspections.length,
              itemBuilder: (context, index) {
                final inspection = _inspections[index];

                return Card(
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(inspection.photoPath),
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(inspection.workOrderId),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Condição : ${inspection.condition ?? '-'}'),
                        Text('Status: ${inspection.status}'),
                        Text(
                          'Data: ${inspection.capturedAt.day}/${inspection.capturedAt.month}/${inspection.capturedAt.year}',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
