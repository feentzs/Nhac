import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:nhac/models/usuario/metodos_pagamento_model.dart';
import 'package:nhac/services/api_client.dart';
import 'package:nhac/utils/safe_parse_helpers.dart';

class PagamentoRepository {
  final _dio = ApiClient().dio;

  Future<List<MetodosPagamentoModel>> buscarPagamentos(String usuarioId) async {
    try {
      final response = await _dio.get('/usuarios/$usuarioId/pagamentos');
      if (response.statusCode == 200 && response.data != null) {
        final List data = response.data;
        return data.map((map) => MetodosPagamentoModel.fromMap(map)).toList();
      }
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.response?.statusCode == 500) {
        return [];
      }
      debugPrint("Erro ao buscar pagamentos: ${e.message}");
      throw Exception('Falha ao buscar métodos de pagamento');
    }
  }

  Future<MetodosPagamentoModel> adicionarPagamento(String usuarioId, MetodosPagamentoModel metodo) async {
    try {
      final response = await _dio.post(
        '/usuarios/$usuarioId/pagamentos',
        data: metodo.toMap(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return MetodosPagamentoModel.fromMap(response.data);
      }
      throw Exception('Erro ao adicionar método de pagamento');
    } on DioException catch (e) {
      final mensagem = extrairMensagemErro(e.response?.data, fallback: 'Erro ao adicionar método de pagamento');
      throw Exception(mensagem);
    }
  }

  Future<void> removerPagamento(String usuarioId, String pagamentoId) async {
    try {
      await _dio.delete('/usuarios/$usuarioId/pagamentos/$pagamentoId');
    } on DioException catch (e) {
      debugPrint("Erro ao remover pagamento: ${e.message}");
      final mensagem = extrairMensagemErro(e.response?.data, fallback: 'Erro ao remover método de pagamento');
      throw Exception(mensagem);
    }
  }

  Future<void> definirComoPadrao(String usuarioId, String pagamentoId) async {
    try {
      await _dio.put('/usuarios/$usuarioId/pagamentos/$pagamentoId', data: {
        'isPadrao': true,
      });
    } on DioException catch (e) {
      debugPrint("Erro ao definir pagamento padrão: ${e.message}");
      final mensagem = extrairMensagemErro(e.response?.data, fallback: 'Erro ao definir método de pagamento padrão');
      throw Exception(mensagem);
    }
  }
}
