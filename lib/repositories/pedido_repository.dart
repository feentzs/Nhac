import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nhac/globals/exceptions.dart';
import 'package:nhac/models/pedido_model.dart';
import 'package:nhac/services/api_client.dart';
import 'package:nhac/utils/safe_parse_helpers.dart';

class PedidoRepository {
  final _dio = ApiClient().dio;

  Future<Map<String, dynamic>> finalizarPedido(PedidoModel pedido) async {
    try {

      final response = await _dio.post(
        '/pedidos',
        data: pedido.toMap(), 
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception("Falha ao criar o pedido. Tente novamente.");
      }
    } on DioException catch (e) {
      throw mapException(e);
    } catch (e) {
      throw Exception("Erro inesperado: $e");
    }
  }
  Future<Map<String, dynamic>> buscarEstatisticas(String usuarioId) async {
    try {
      final response = await _dio.get('/usuarios/$usuarioId/estatisticas');
      if (response.statusCode == 200) {
        return response.data;
      }
      return {'totalPedidos': 0, 'avaliacoes': 0, 'cupons': 0};
    } on DioException catch (e) {
      debugPrint("Erro ao buscar estatísticas: ${e.message}");
      return {'totalPedidos': 0, 'avaliacoes': 0, 'cupons': 0};
    }
  }

  Future<List<PedidoModel>> buscarHistorico(String usuarioId, {int page = 0, int size = 10}) async {
    try {
      final response = await _dio.get(
        '/usuarios/$usuarioId/pedidos',
        queryParameters: {'page': page, 'size': size},
      );
      if (response.statusCode == 200 && response.data != null) {
        final List data = extrairLista(response.data);
        return data.map((map) => PedidoModel.fromMap(map)).toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      debugPrint("Erro ao buscar histórico: ${e.message}");
      throw Exception('Falha ao buscar histórico de pedidos');
    }
  }
}
