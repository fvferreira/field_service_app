import 'package:field_service_app/models/inspection.dart';
import 'package:field_service_app/services/database_service.dart';
import 'package:field_service_app/services/inspection_sync_service.dart';

class SyncService {
  final DatabaseService _databaseService;
  final InspectionSyncService _inspectionSyncService;

  SyncService(this._databaseService, this._inspectionSyncService);

  Future<void> syncPendingInspections() async {
    final inspections = await _databaseService.getPendingInspections();
    for (final inspection in inspections) {
      try {
        await syncInspection(inspection);
      } catch (_) {}
    }
  }

  Future<void> syncInspection(Inspection inspection) async {
    try {
      final serverId = await _inspectionSyncService.syncInspection(inspection);

      await _databaseService.updateInspectionStatus(
        clientId: inspection.clientId,
        status: 'synced',
        serverId: serverId,
        errorMessage: null,
      );
    } catch (error) {
      await _databaseService.updateInspectionStatus(
        clientId: inspection.clientId,
        status: 'failed',
        errorMessage: error.toString(),
      );

      rethrow;
    }
  }
}
