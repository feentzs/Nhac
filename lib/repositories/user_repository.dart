import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:nhac/models/usuario/usuario_model.dart';
import 'package:nhac/services/api_client.dart';

class UserRepository {
  final _dio = ApiClient().dio;

  Future<UsuarioModel?> buscarUsuario(String id) async {
    try {
      final response = await _dio.get('/usuarios/$id');
      if (response.statusCode == 200 && response.data != null) {
        return UsuarioModel.fromMap(response.data);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null; 
      debugPrint("Erro ao buscar utilizador na API: ${e.message}");
      rethrow;
    }
  }

  Future<void> salvarUsuario(UsuarioModel usuario) async {
    try {
      await _dio.post('/usuarios', data: usuario.toMap());
    } catch (e) {
      debugPrint("Erro ao salvar utilizador na API: $e");
      rethrow;
    }
  }

  Future<void> atualizarDadosUsuario(String id, Map<String, dynamic> dados) async {
    try {
      await _dio.put('/usuarios/$id', data: dados);
    } catch (e) {
      debugPrint("Erro ao atualizar utilizador na API: $e");
      rethrow;
    }
  }
}
