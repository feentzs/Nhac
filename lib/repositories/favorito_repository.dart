import 'package:nhac/models/usuario/favoritos_model.dart';
import 'package:flutter/foundation.dart';

class FavoritoRepository {
  // final _dio = ApiClient().dio;

  Future<List<FavoritosModel>> buscarFavoritos(String usuarioId) async {
    // API não implementada no backend ainda
    return [];
  }

  Future<FavoritosModel> favoritarProduto(String usuarioId, String produtoId) async {
    // API não implementada no backend ainda
    return FavoritosModel(id: 'mock', usuarioId: usuarioId, produtoId: produtoId, imagemUrl: '', nome: '', preco: 3);
  }

  Future<void> desfavoritarProduto(String usuarioId, String produtoId) async {
    // API não implementada no backend ainda
    return;
  }

  Future<int> contarFavoritos(String produtoId) async {
    // API não implementada no backend ainda
    return 0;
  }
}
