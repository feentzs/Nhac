import 'package:nhac/models/loja/lojas.dart';
import 'package:nhac/services/api_client.dart';

class LojaRepository {
  final _dio = ApiClient().dio;

  Future<List<LojasModel>> buscarLojas({int page = 0, int size = 10}) async {
    final response = await _dio.get(
      '/lojas',
      queryParameters: {'page': page, 'size': size},
    );

    final List<dynamic> conteudo = response.data['content'];
    return conteudo.map((map) => LojasModel.fromMap(map)).toList();
  }

  Future<LojasModel?> buscarLoja(String lojaId) async {
    final response = await _dio.get('/lojas/$lojaId');
    return LojasModel.fromMap(response.data);
  }

  /// Busca lojas por nome. O backend não tem filtro por nome em GET /lojas
  /// (só paginação) — então buscamos uma página maior e filtramos aqui.
  /// Funcional para o volume atual de lojas; se a base crescer muito, o
  /// ideal é adicionar um parâmetro 'nome' no backend em vez disso.
  Future<List<LojasModel>> buscarLojasPorNome(String termo) async {
    final termoBusca = termo.trim().toLowerCase();
    if (termoBusca.isEmpty) return [];

    final response = await _dio.get(
      '/lojas',
      queryParameters: {'page': 0, 'size': 100},
    );

    final List<dynamic> conteudo = response.data['content'];
    final todasAsLojas = conteudo.map((map) => LojasModel.fromMap(map)).toList();

    return todasAsLojas
        .where((loja) => loja.nome.toLowerCase().contains(termoBusca))
        .toList();
  }
}
