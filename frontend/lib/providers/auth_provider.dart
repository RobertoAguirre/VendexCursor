import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/business.dart';

class AuthProvider extends ChangeNotifier {
  Business? _business;
  String? _token;
  bool _isLoading = true;
  String? _error;

  Business? get business => _business;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null && _business != null;
  String? get error => _error;

  AuthProvider() {
    _loadStoredAuth();
  }

  Future<void> _loadStoredAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
      
      if (_token != null) {
        await _loadProfile();
      }
    } catch (e) {
      _error = 'Error cargando autenticación: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final dio = Dio();
      final response = await dio.post(
        '${ApiConfig.apiBaseUrl}${ApiConfig.login}',
        data: {'email': email, 'password': password},
        options: Options(headers: ApiConfig.defaultHeaders),
      );

      if (response.statusCode == 200) {
        _token = response.data['token'];
        _business = Business.fromJson(response.data['business']);
        
        // Guardar en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error en login: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? businessType,
    String? description,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final dio = Dio();
      final response = await dio.post(
        '${ApiConfig.apiBaseUrl}${ApiConfig.register}',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'business_type': businessType,
          'description': description,
        },
        options: Options(headers: ApiConfig.defaultHeaders),
      );

      if (response.statusCode == 201) {
        _token = response.data['token'];
        _business = Business.fromJson(response.data['business']);
        
        // Guardar en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error en registro: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadProfile() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        '${ApiConfig.apiBaseUrl}${ApiConfig.profile}',
        options: Options(headers: ApiConfig.authHeaders(_token!)),
      );

      if (response.statusCode == 200) {
        _business = Business.fromJson(response.data['business']);
      }
    } catch (e) {
      _error = 'Error cargando perfil: $e';
      await logout();
    }
  }

  Future<void> logout() async {
    _business = null;
    _token = null;
    _error = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 