import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Obtener productos del negocio
  Future<void> loadProducts() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // TODO: Implementar cuando tengamos AuthProvider
      // final token = context.read<AuthProvider>().token;
      
      final dio = Dio();
      final response = await dio.get(
        '${ApiConfig.apiBaseUrl}${ApiConfig.products}',
        options: Options(headers: ApiConfig.defaultHeaders),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['products'];
        _products = data.map((json) => Product.fromJson(json)).toList();
      }
    } catch (e) {
      _error = 'Error cargando productos: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Crear producto
  Future<bool> createProduct(Product product) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final dio = Dio();
      final response = await dio.post(
        '${ApiConfig.apiBaseUrl}${ApiConfig.products}',
        data: product.toJson(),
        options: Options(headers: ApiConfig.defaultHeaders),
      );

      if (response.statusCode == 201) {
        final newProduct = Product.fromJson(response.data['product']);
        _products.add(newProduct);
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error creando producto: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Actualizar producto
  Future<bool> updateProduct(Product product) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final dio = Dio();
      final response = await dio.put(
        '${ApiConfig.apiBaseUrl}${ApiConfig.products}/${product.id}',
        data: product.toJson(),
        options: Options(headers: ApiConfig.defaultHeaders),
      );

      if (response.statusCode == 200) {
        final updatedProduct = Product.fromJson(response.data['product']);
        final index = _products.indexWhere((p) => p.id == product.id);
        if (index != -1) {
          _products[index] = updatedProduct;
        }
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error actualizando producto: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Eliminar producto
  Future<bool> deleteProduct(int productId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final dio = Dio();
      final response = await dio.delete(
        '${ApiConfig.apiBaseUrl}${ApiConfig.products}/$productId',
        options: Options(headers: ApiConfig.defaultHeaders),
      );

      if (response.statusCode == 200) {
        _products.removeWhere((p) => p.id == productId);
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error eliminando producto: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Actualizar stock
  Future<bool> updateStock(int productId, int newStock) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final dio = Dio();
      final response = await dio.patch(
        '${ApiConfig.apiBaseUrl}${ApiConfig.products}/$productId/stock',
        data: {'stock': newStock},
        options: Options(headers: ApiConfig.defaultHeaders),
      );

      if (response.statusCode == 200) {
        final index = _products.indexWhere((p) => p.id == productId);
        if (index != -1) {
          _products[index] = _products[index].copyWith(stock: newStock);
        }
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error actualizando stock: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Importar productos (para onboarding)
  Future<bool> importProducts(List<Product> products) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final dio = Dio();
      final response = await dio.post(
        '${ApiConfig.apiBaseUrl}${ApiConfig.importProducts}',
        data: {
          'products': products.map((p) => p.toJson()).toList(),
        },
        options: Options(headers: ApiConfig.defaultHeaders),
      );

      if (response.statusCode == 201) {
        final List<dynamic> data = response.data['products'];
        _products = data.map((json) => Product.fromJson(json)).toList();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Error importando productos: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener producto por ID
  Product? getProductById(int id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  // Filtrar productos activos
  List<Product> get activeProducts {
    return _products.where((product) => product.active).toList();
  }

  // Filtrar productos con stock
  List<Product> get productsWithStock {
    return _products.where((product) => product.hasStock).toList();
  }

  // Buscar productos
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _products;
    
    return _products.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
             product.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
