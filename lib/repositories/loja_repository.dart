import 'package:flutter/material.dart';
import 'package:nhac/globals/exceptions.dart';
import 'package:nhac/models/loja/lojas.dart';
import 'package:nhac/services/api_client.dart';
import 'package:nhac/utils/safe_parse_helpers.dart';

class LojaRepository {
  final _dio = ApiClient().dio;

  Future<List<LojasModel>> buscarLojas({int page = 0, int size = 10}) async {
    try {
      final response = await _dio.get(
        '/lojas',
        queryParameters: {'page': page, 'size': size},
      );

      final List<dynamic> conteudo = extrairLista(response.data);
      return conteudo.map((map) => LojasModel.fromMap(map)).toList();
    } catch (e) {
      throw mapException(e);
    }
  }

  Future<LojasModel?> buscarLoja(String lojaId) async {
    try {
      final response = await _dio.get('/lojas/$lojaId');
      return LojasModel.fromMap(response.data);
    } catch (e) {
      debugPrint("Erro ao buscar loja $lojaId: $e");
      return null;
    }
  }


  Future<List<LojasModel>> buscarLojasPorNome(String termo) async {
    final termoBusca = termo.trim().toLowerCase();
    if (termoBusca.isEmpty) return [];

    try {
      final response = await _dio.get(
        '/lojas',
        queryParameters: {'page': 0, 'size': 100},
      );

      final List<dynamic> conteudo = extrairLista(response.data);
      final todasAsLojas = conteudo.map((map) => LojasModel.fromMap(map)).toList();

      return todasAsLojas
          .where((loja) => loja.nome.toLowerCase().contains(termoBusca))
          .toList();
    } catch (e) {
      throw mapException(e);
    }
  }
  Future<Map<String, dynamic>> calcularFrete(String lojaId, String enderecoId) async {
    try {
      final response = await _dio.post(
        '/lojas/$lojaId/calcular-frete',
        data: {'enderecoId': enderecoId},
      );
      if (response.statusCode == 200) {
        return response.data; // { 'valor': 5.50, 'tempoEstimado': '30 - 50 min' }
      }
      return {'valor': 0.0, 'tempoEstimado': 'N/A'};
    } catch (e) {
      throw mapException(e);
    }
  }

  Future<void> seguirLoja(String usuarioId, String lojaId) async {
    try {
      await _dio.post('/usuarios/$usuarioId/seguindo/$lojaId');
    } catch (e) {
      throw mapException(e);
    }
  }

  Future<void> deixarDeSeguir(String usuarioId, String lojaId) async {
    try {
      await _dio.delete('/usuarios/$usuarioId/seguindo/$lojaId');
    } catch (e) {
      throw mapException(e);
    }
  }

  Future<int> contarSeguidores(String lojaId) async {
    try {
      final response = await _dio.get('/lojas/$lojaId/seguidores/contagem');
      if (response.statusCode == 200) {
        final raw = response.data;
        if (raw is int) return raw;
        if (raw is Map) return safeInt(raw['total']);
        return 0;
      }
      return 0;
    } catch (e) {
      throw mapException(e);
    }
  }

  Future<bool> estaSeguindo(String usuarioId, String lojaId) async {
    try {
      final response = await _dio.get('/usuarios/$usuarioId/seguindo/$lojaId');
      return response.statusCode == 200 && response.data == true;
    } catch (e) {
      throw mapException(e);
    }
  }
}
