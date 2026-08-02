import 'package:dio/dio.dart';
import 'package:nhac/globals/exceptions.dart';
import 'package:nhac/models/avaliacao_model.dart';
import 'package:nhac/services/api_client.dart';

/// NOVO — precisa que o backend exponha POST /avaliacoes (ver contrato no
/// final da conversa). A tabela tb_avaliacoes e os triggers que recalculam
/// a média da loja já existem no banco — só falta a rota.
class AvaliacaoRepository {
  final _dio = ApiClient().dio;

  Future<void> avaliarPedido(AvaliacaoModel avaliacao) async {
    try {
      await _dio.post('/avaliacoes', data: avaliacao.toMap());
    } on DioException catch (e) {
      throw mapException(e);
    }
  }
}
