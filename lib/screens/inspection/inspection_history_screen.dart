import 'package:field_service_app/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:field_service_app/models/inspection.dart';
import 'dart:io';
import 'package:field_service_app/services/inspection_sync_service.dart';
import 'package:field_service_app/services/sync_service.dart';
import 'package:field_service_app/services/token_storage_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class InspectionHistoryScreen extends StatefulWidget {
  const InspectionHistoryScreen({super.key});

  @override
  State<InspectionHistoryScreen> createState() =>
      _InspectionHistoryScreenState();
}

class _InspectionHistoryScreenState extends State<InspectionHistoryScreen> {
  final DatabaseService _databaseService = DatabaseService();

  final SyncService _syncService = SyncService(
    DatabaseService(),
    InspectionSyncService(TokenStorageService(const FlutterSecureStorage())),
  );

  List<Inspection> _inspections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInspections();
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Pendente';
      case 'synced':
        return 'Sincronizada';
      case 'failed':
        return 'Falhou';
      case 'draft':
        return 'Rascunho';
      default:
        return status;
    }
  }

  Future<void> _syncInspection(Inspection inspection) async {
    try {
      await _syncService.syncInspection(inspection);
      await _loadInspections();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inspeção sincronizada com sucesso')),
      );
    } catch (error) {
      await _loadInspections();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível sincronizar a inspeção'),
        ),
      );
    }
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
                        Text('Status: ${_formatStatus(inspection.status)}'),
                        Text(
                          'Data: ${inspection.capturedAt.day}/${inspection.capturedAt.month}/${inspection.capturedAt.year}',
                        ),
                      ],
                    ),
                    trailing: inspection.status == 'synced'
                        ? const Icon(Icons.check_circle)
                        : IconButton(
                            icon: const Icon(Icons.sync),
                            onPressed: () {
                              _syncInspection(inspection);
                            },
                          ),
                  ),
                );
              },
            ),
    );
  }
}
