import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/business.dart';
import 'auth_provider.dart';

class BusinessStats {
  final int products;
  final int conversations;
  final int sales;
  final double totalRevenue;

  BusinessStats({
    required this.products,
    required this.conversations,
    required this.sales,
    required this.totalRevenue,
  });

  factory BusinessStats.fromJson(Map<String, dynamic> json) {
    return BusinessStats(
      products: json['products'] ?? 0,
      conversations: json['conversations'] ?? 0,
      sales: json['sales'] ?? 0,
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
    );
  }
}

class BusinessProvider extends ChangeNotifier {
  Business? _business;
  BusinessStats? _stats;
  bool _isLoading = false;
  String? _error;

  Business? get business => _business;
  BusinessStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadBusinessInfo() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final authProvider = AuthProvider();
      final token = authProvider.token;
      
      if (token == null) {
        _error = 'No hay token de autenticación';
        return;
      }

      final dio = Dio();
      final response = await dio.get(
        '${ApiConfig.baseUrl}${ApiConfig.business}',
        options: Options(headers: ApiConfig.authHeaders(token)),
      );

      if (response.statusCode == 200) {
        _business = Business.fromJson(response.data['business']);
        _stats = BusinessStats.fromJson(response.data['stats']);
      }
    } catch (e) {
      _error = 'Error cargando información del negocio: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> configureWhatsApp(String whatsappNumber) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final authProvider = AuthProvider();
      final token = authProvider.token;
      
      if (token == null) {
        _error = 'No hay token de autenticación';
        return false;
      }

      final dio = Dio();
      final response = await dio.post(
        '${ApiConfig.baseUrl}${ApiConfig.whatsapp}',
        data: {'whatsapp_number': whatsappNumber},
        options: Options(headers: ApiConfig.authHeaders(token)),
      );

      if (response.statusCode == 200) {
        await loadBusinessInfo(); // Recargar datos
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error configurando WhatsApp: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> configureStripe({
    required String secretKey,
    String? webhookSecret,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final authProvider = AuthProvider();
      final token = authProvider.token;
      
      if (token == null) {
        _error = 'No hay token de autenticación';
        return false;
      }

      final dio = Dio();
      final response = await dio.post(
        '${ApiConfig.baseUrl}${ApiConfig.stripe}',
        data: {
          'stripe_secret_key': secretKey,
          'stripe_webhook_secret': webhookSecret,
        },
        options: Options(headers: ApiConfig.authHeaders(token)),
      );

      if (response.statusCode == 200) {
        await loadBusinessInfo(); // Recargar datos
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error configurando Stripe: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> configureAssistantPersonality(String personality) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final authProvider = AuthProvider();
      final token = authProvider.token;
      
      if (token == null) {
        _error = 'No hay token de autenticación';
        return false;
      }

      final dio = Dio();
      final response = await dio.post(
        '${ApiConfig.baseUrl}${ApiConfig.assistantPersonality}',
        data: {'personality': personality},
        options: Options(headers: ApiConfig.authHeaders(token)),
      );

      if (response.statusCode == 200) {
        await loadBusinessInfo(); // Recargar datos
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error configurando personalidad: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateBusiness({
    String? name,
    String? phone,
    String? businessType,
    String? description,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final authProvider = AuthProvider();
      final token = authProvider.token;
      
      if (token == null) {
        _error = 'No hay token de autenticación';
        return false;
      }

      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      if (businessType != null) data['business_type'] = businessType;
      if (description != null) data['description'] = description;

      final dio = Dio();
      final response = await dio.put(
        '${ApiConfig.baseUrl}${ApiConfig.business}',
        data: data,
        options: Options(headers: ApiConfig.authHeaders(token)),
      );

      if (response.statusCode == 200) {
        await loadBusinessInfo(); // Recargar datos
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error actualizando negocio: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 