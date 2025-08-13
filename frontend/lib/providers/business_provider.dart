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
  bool _onboardingCompleted = false;

  Business? get business => _business;
  BusinessStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get onboardingCompleted => _onboardingCompleted;

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
        '${ApiConfig.apiBaseUrl}${ApiConfig.business}',
        options: Options(headers: ApiConfig.authHeaders(token)),
      );

      if (response.statusCode == 200) {
        _business = Business.fromJson(response.data['business']);
        _stats = BusinessStats.fromJson(response.data['stats']);
        _onboardingCompleted = _checkOnboardingStatus();
      }
    } catch (e) {
      _error = 'Error cargando información del negocio: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _checkOnboardingStatus() {
    if (_business == null) return false;
    
    // Verificar que tenga todas las credenciales necesarias
    return _business!.whatsappNumber != null &&
           _business!.ultramsgInstanceId != null &&
           _business!.ultramsgToken != null &&
           _business!.stripeSecretKey != null &&
           _business!.stripePublishableKey != null &&
           _business!.anthropicApiKey != null &&
           _business!.assistantPersonality != null &&
           (_stats?.products ?? 0) > 0;
  }

  Future<bool> configureWhatsApp({
    required String whatsappNumber,
    required String ultramsgInstanceId,
    required String ultramsgToken,
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
        '${ApiConfig.apiBaseUrl}${ApiConfig.whatsapp}',
        data: {
          'whatsapp_number': whatsappNumber,
          'ultramsg_instance_id': ultramsgInstanceId,
          'ultramsg_token': ultramsgToken,
        },
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
    required String publishableKey,
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
        '${ApiConfig.apiBaseUrl}${ApiConfig.stripe}',
        data: {
          'stripe_secret_key': secretKey,
          'stripe_publishable_key': publishableKey,
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

  Future<bool> configureAnthropic(String apiKey) async {
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
        '${ApiConfig.apiBaseUrl}/api/business/anthropic',
        data: {'anthropic_api_key': apiKey},
        options: Options(headers: ApiConfig.authHeaders(token)),
      );

      if (response.statusCode == 200) {
        await loadBusinessInfo(); // Recargar datos
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error configurando Anthropic: $e';
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
        '${ApiConfig.apiBaseUrl}${ApiConfig.assistantPersonality}',
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
        '${ApiConfig.apiBaseUrl}${ApiConfig.business}',
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

  Future<bool> markOnboardingComplete() async {
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
        '${ApiConfig.apiBaseUrl}/api/business/onboarding-complete',
        options: Options(headers: ApiConfig.authHeaders(token)),
      );

      if (response.statusCode == 200) {
        _onboardingCompleted = true;
        await loadBusinessInfo(); // Recargar datos
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error marcando onboarding como completado: $e';
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