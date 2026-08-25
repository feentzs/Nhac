import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:nhac/models/usuario/usuario_model.dart';
import 'package:nhac/services/api_client.dart';
import 'package:nhac/globals/exceptions.dart';

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
      throw mapException(e);
    }
  }

  Future<void> salvarUsuario(UsuarioModel usuario) async {
    try {
      await _dio.post('/usuarios', data: usuario.toMap());
    } catch (e) {
      debugPrint("Erro ao salvar utilizador na API: $e");
      throw mapException(e);
    }
  }

  Future<void> atualizarDadosUsuario(String id, Map<String, dynamic> dados) async {
    try {
      await _dio.put('/usuarios/$id', data: dados);
    } catch (e) {
      debugPrint("Erro ao atualizar utilizador na API: $e");
      throw mapException(e);
    }
  }

  Future<String> uploadFotoPerfil(String id, String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: 'perfil.jpg'),
      });
      final response = await _dio.post('/usuarios/$id/foto', data: formData);
      return response.data['imagemUrl'] as String;
    } catch (e) {
      debugPrint("Erro ao fazer upload da foto na API: $e");
      throw mapException(e);
    }
  }
}
