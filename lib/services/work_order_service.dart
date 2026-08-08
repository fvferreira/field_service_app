import 'dart:convert';
import 'package:field_service_app/core/api_constants.dart';
import 'package:field_service_app/models/work_order.dart';
import 'package:field_service_app/services/token_storage_service.dart';
import 'package:http/http.dart' as http;

class WorkOrderService {
  final TokenStorageService _tokenStorageService;

  WorkOrderService(this._tokenStorageService);

  Future<List<WorkOrder>> getWorkOrders() async {
    final token = await _tokenStorageService.getToken();

    if (token == null) {
      throw Exception('Usuário não autenticado');
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/work-orders');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;

      return jsonList
          .map((item) => WorkOrder.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    if (response.statusCode == 401) {
      throw Exception('Sessão inválida ou expirada');
    }
    throw Exception('Não foi possível carregar as ordens de serviço');
  }
}
