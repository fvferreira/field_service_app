import 'package:field_service_app/models/user.dart';
import 'package:field_service_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:field_service_app/services/token_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final TokenStorageService _tokenStorageService;

  AuthProvider(this._authService, this._tokenStorageService);

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(
        email: email,
        password: password,
      );

      await _tokenStorageService.saveToken(response.accessToken);

      _user = response.user;
      return true;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception:', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
