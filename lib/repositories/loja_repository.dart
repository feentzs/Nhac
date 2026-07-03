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
}
