import 'package:nhac/models/loja/lojas.dart';
import 'package:nhac/services/api_client.dart';

class LojaRepository {
  final _dio = ApiClient().dio;

  Future<List<LojasModel>> buscarLojas({int page = 0, int size = 10}) async {
    try {
      final response = await _dio.get(
        '/lojas',
        queryParameters: {'page': page, 'size': size},
      );

      final List<dynamic> conteudo = response.data['content'];
      return conteudo.map((map) => LojasModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception("Erro ao buscar lojas: $e");
    }
  }

  Future<LojasModel?> buscarLoja(String lojaId) async {
    try {

     final response = await _dio.get('/lojas/$lojaId');
      return LojasModel.fromMap(response.data);
    } catch (e) {

      throw Exception("Erro ao buscar loja: $e");
      
    }
  }
}
