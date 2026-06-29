import 'package:dio/dio.dart';
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
        return response.data.toString();
      } else {
        throw Exception("Falha ao criar o pedido. Tente novamente.");
      }
    } on DioException catch (e) {

      if (e.response != null && e.response?.statusCode == 400) {
        final mensagemErro = e.response?.data['mensagem'] ?? 'Dados do pedido inválidos.';
        throw Exception("Erro de Validação: $mensagemErro");
      }
      throw Exception("Erro de conexão com o servidor. Tente novamente.");
    }
  }
}