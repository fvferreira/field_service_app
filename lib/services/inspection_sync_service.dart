import 'dart:convert';
import 'package:field_service_app/core/api_constants.dart';
import 'package:field_service_app/models/inspection.dart';
import 'package:field_service_app/services/token_storage_service.dart';
import 'package:http/http.dart' as http;

class InspectionSyncService {
  final TokenStorageService _tokenStorageService;

  InspectionSyncService(this._tokenStorageService);

  Future<String> syncInspection(Inspection inspection) async {
    final token = await _tokenStorageService.getToken();

    if (token == null) {
      throw Exception('Usuário não autenticado');
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/inspections');

    final request = http.MultipartRequest('POST', url);

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['clientId'] = inspection.clientId;
    request.fields['workOrderId'] = inspection.workOrderId;
    request.fields['observation'] = inspection.observation;
    request.fields['latitude'] = inspection.latitude.toString();
    request.fields['longitude'] = inspection.longitude.toString();
    request.fields['capturedAt'] = inspection.capturedAt.toIso8601String();
    if (inspection.condition != null) {
      request.fields['condition'] = inspection.condition!;
    }

    request.files.add(
      await http.MultipartFile.fromPath('photo', inspection.photoPath),
    );
    final streamResponse = await request.send();
    final response = await http.Response.fromStream(streamResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['id'] as String;
    }
    throw Exception('Erro ${response.statusCode}: ${response.body}');
  }
}
