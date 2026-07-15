import 'package:dio/dio.dart';
import 'package:nhac/globals/exceptions.dart';
import 'package:nhac/models/pedido_model.dart';
import 'package:nhac/services/api_client.dart';

class PedidoRepository {
  final _dio = ApiClient().dio;

  Future<String> finalizarPedido(PedidoModel pedido) async {
    try {

      final response = await _dio.post(
        '/pedidos',
        data: pedido.toMap(), 
      );

      if (response.statusCode == 201) {
        // BUG CORRIGIDO: o backend passou a devolver um JSON explícito
        // ({"pedidoId": "..."}) em vez de uma String pura — antes disso,
        // dependendo de como o Content-Type era negociado, o Dio às vezes
        // tentava fazer JSON parse de um texto que não era JSON válido e
        // quebrava com "FormatException: Unexpected character".
        final data = response.data;
        if (data is Map && data.containsKey('pedidoId')) {
          return data['pedidoId'].toString();
        }
        return data.toString();
      } else {
        throw Exception("Falha ao criar o pedido. Tente novamente.");
      }
    } on DioException catch (e) {
      throw mapException(e);
    } catch (e) {
      throw Exception("Erro inesperado: $e");
    }
  }

  /// Lista os pedidos do usuário logado, do mais recente pro mais antigo.
  /// NOVO — precisa que o backend exponha GET /pedidos (ver contrato no
  /// final da conversa). usuarioId vem implícito do token, igual em
  /// POST /pedidos.
  Future<List<PedidoModel>> buscarMeusPedidos({int page = 0, int size = 20}) async {
    try {
      final response = await _dio.get(
        '/pedidos',
        queryParameters: {'page': page, 'size': size},
      );
      final List<dynamic> conteudo = response.data['content'];
      return conteudo.map((map) => PedidoModel.fromMap(map)).toList();
    } on DioException catch (e) {
      throw mapException(e);
    }
  }

  /// Detalhe completo de um pedido, incluindo a linha do tempo de status.
  /// NOVO — precisa que o backend exponha GET /pedidos/{id}.
  Future<PedidoModel> buscarPedidoPorId(String pedidoId) async {
    try {
      final response = await _dio.get('/pedidos/$pedidoId');
      return PedidoModel.fromMap(response.data);
    } on DioException catch (e) {
      throw mapException(e);
    }
  }
}
