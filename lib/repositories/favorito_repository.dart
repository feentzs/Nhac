import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:nhac/models/usuario/favoritos_model.dart';
import 'package:nhac/services/api_client.dart';

class FavoritoRepository {
  final _dio = ApiClient().dio;

  Future<List<FavoritosModel>> buscarFavoritos(String usuarioId) async {
    try {
      final response = await _dio.get('/usuarios/$usuarioId/favoritos');
      if (response.statusCode == 200 && response.data != null) {
        final List data = response.data;
        return data.map((map) => FavoritosModel.fromMap(map, map['id']?.toString() ?? '')).toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      debugPrint("Erro ao buscar favoritos: ${e.message}");
      throw Exception('Falha ao buscar favoritos');
    }
  }

  Future<FavoritosModel> favoritarProduto(String usuarioId, String produtoId) async {
    try {
      final response = await _dio.post('/usuarios/$usuarioId/favoritos', data: {
        'produtoId': produtoId,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        final map = response.data;
        return FavoritosModel.fromMap(map, map['id']?.toString() ?? '');
      }
      throw Exception('Erro ao favoritar produto');
    } on DioException catch (e) {
      final mensagem = e.response?.data?['message'] ?? 'Erro ao favoritar produto';
      throw Exception(mensagem);
    }
  }

  Future<void> desfavoritarProduto(String usuarioId, String produtoId) async {
    try {
      // Usando query params ou path vars conforme o endpoint
      await _dio.delete('/usuarios/$usuarioId/favoritos/$produtoId');
    } on DioException catch (e) {
      debugPrint("Erro ao desfavoritar: ${e.message}");
      final mensagem = e.response?.data?['message'] ?? 'Erro ao remover dos favoritos';
      throw Exception(mensagem);
    }
  }

  Future<int> contarFavoritos(String produtoId) async {
    try {
      final response = await _dio.get('/produtos/$produtoId/favoritos/contagem');
      if (response.statusCode == 200) {
        return (response.data['total'] ?? response.data ?? 0) as int;
      }
      return 0;
    } on DioException catch (e) {
      debugPrint("Erro ao contar favoritos: ${e.message}");
      return 0;
    }
  }
}
