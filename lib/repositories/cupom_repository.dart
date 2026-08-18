import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:nhac/models/usuario/cupom_model.dart';
import 'package:nhac/services/api_client.dart';

class CupomRepository {
  final _dio = ApiClient().dio;

  Future<List<CupomModel>> buscarCupons(String usuarioId) async {
    try {
      final response = await _dio.get('/usuarios/$usuarioId/cupons');
      if (response.statusCode == 200 && response.data != null) {
        final List data = response.data;
        return data.map((map) => CupomModel.fromMap(map)).toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      debugPrint("Erro ao buscar cupons: ${e.message}");
      throw Exception('Falha ao buscar cupons');
    }
  }

  Future<CupomModel> resgatarCupom(String usuarioId, String codigo) async {
    try {
      final response = await _dio.post('/usuarios/$usuarioId/cupons/resgatar', data: {
        'codigo': codigo,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return CupomModel.fromMap(response.data);
      }
      throw Exception('Erro ao resgatar cupom');
    } on DioException catch (e) {
      final mensagem = e.response?.data?['message'] ?? 'Erro ao resgatar cupom';
      throw Exception(mensagem);
    }
  }

  Future<CupomModel> validarCupom(String codigo) async {
    try {
      final response = await _dio.post('/cupons/validar', data: {
        'codigo': codigo,
      });
      if (response.statusCode == 200) {
        return CupomModel.fromMap(response.data);
      }
      throw Exception('Cupom inválido');
    } on DioException catch (e) {
      final mensagem = e.response?.data?['message'] ?? 'Erro ao validar cupom';
      throw Exception(mensagem);
    }
  }
}
