import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/conversation.dart';

class ConversationProvider extends ChangeNotifier {
  List<Conversation> _conversations = [];
  bool _isLoading = false;
  String? _error;

  List<Conversation> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Obtener conversaciones del negocio
  Future<void> loadConversations() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // TODO: Implementar cuando tengamos AuthProvider
      // final token = context.read<AuthProvider>().token;
      
      final dio = Dio();
      final response = await dio.get(
        '${ApiConfig.apiBaseUrl}${ApiConfig.conversations}',
        options: Options(headers: ApiConfig.defaultHeaders),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['conversations'];
        _conversations = data.map((json) => Conversation.fromJson(json)).toList();
      }
    } catch (e) {
      _error = 'Error cargando conversaciones: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener conversación por ID
  Future<Conversation?> getConversation(int id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final dio = Dio();
      final response = await dio.get(
        '${ApiConfig.apiBaseUrl}${ApiConfig.conversations}/$id',
        options: Options(headers: ApiConfig.defaultHeaders),
      );

      if (response.statusCode == 200) {
        return Conversation.fromJson(response.data['conversation']);
      }
      return null;
    } catch (e) {
      _error = 'Error cargando conversación: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener mensajes de una conversación
  Future<List<Message>> getMessages(int conversationId) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        '${ApiConfig.apiBaseUrl}${ApiConfig.conversations}/$conversationId/messages',
        options: Options(headers: ApiConfig.defaultHeaders),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['messages'];
        return data.map((json) => Message.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      _error = 'Error cargando mensajes: $e';
      return [];
    }
  }

  // Actualizar estado de conversación
  Future<bool> updateConversationStatus(int id, String status) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final dio = Dio();
      final response = await dio.patch(
        '${ApiConfig.apiBaseUrl}${ApiConfig.conversations}/$id/status',
        data: {'status': status},
        options: Options(headers: ApiConfig.defaultHeaders),
      );

      if (response.statusCode == 200) {
        final index = _conversations.indexWhere((c) => c.id == id);
        if (index != -1) {
          _conversations[index] = _conversations[index].copyWith(status: status);
        }
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error actualizando conversación: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cerrar conversación
  Future<bool> closeConversation(int id) async {
    return await updateConversationStatus(id, 'closed');
  }

  // Buscar conversaciones
  Future<List<Conversation>> searchConversations(String query) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        '${ApiConfig.apiBaseUrl}${ApiConfig.searchConversations}',
        queryParameters: {'q': query},
        options: Options(headers: ApiConfig.defaultHeaders),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['conversations'];
        return data.map((json) => Conversation.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      _error = 'Error buscando conversaciones: $e';
      return [];
    }
  }

  // Obtener estadísticas de conversaciones
  Future<Map<String, dynamic>?> getConversationStats() async {
    try {
      final dio = Dio();
      final response = await dio.get(
        '${ApiConfig.apiBaseUrl}${ApiConfig.conversationStats}',
        options: Options(headers: ApiConfig.defaultHeaders),
      );

      if (response.statusCode == 200) {
        return response.data['stats'];
      }
      return null;
    } catch (e) {
      _error = 'Error cargando estadísticas: $e';
      return null;
    }
  }

  // Filtrar conversaciones por estado
  List<Conversation> getConversationsByStatus(String status) {
    return _conversations.where((c) => c.status == status).toList();
  }

  // Obtener conversaciones activas
  List<Conversation> get activeConversations {
    return getConversationsByStatus('active');
  }

  // Obtener conversaciones cerradas
  List<Conversation> get closedConversations {
    return getConversationsByStatus('closed');
  }

  // Obtener conversación por teléfono
  Conversation? getConversationByPhone(String phone) {
    try {
      return _conversations.firstWhere((c) => c.customerPhone == phone);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
