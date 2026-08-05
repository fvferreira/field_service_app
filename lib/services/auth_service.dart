import 'dart:convert';
import 'package:field_service_app/models/auth_response.dart';
import 'package:http/http.dart' as http;
import 'package:field_service_app/core/api_constants.dart';

class AuthService {
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;
      return AuthResponse.fromJson(json);
    }

    if (response.statusCode == 401) {
      throw Exception('Credenciais inválidas');
    }

    throw Exception('Não foi possível realizar o login!');
  }
}
