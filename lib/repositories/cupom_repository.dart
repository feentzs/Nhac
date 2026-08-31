import 'package:nhac/models/usuario/cupom_model.dart';

class CupomRepository {
  // final _dio = ApiClient().dio;

  Future<List<CupomModel>> buscarCupons(String usuarioId) async {
    // API não implementada no backend ainda
    return [];
  }

  Future<CupomModel> resgatarCupom(String usuarioId, String codigo) async {
    throw Exception('Funcionalidade de cupons temporariamente indisponível');
  }

  Future<CupomModel> validarCupom(String codigo) async {
    throw Exception('Funcionalidade de cupons temporariamente indisponível');
  }
}
