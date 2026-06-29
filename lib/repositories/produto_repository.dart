import 'package:flutter/material.dart';
import 'package:nhac/models/produto/produtos.dart';
import 'package:nhac/services/api_client.dart';

class ProdutoRepository {
  final _dio = ApiClient().dio;

  Future<List<ProdutosModel>> buscarPromocoes() async {
    try {

      final response = await _dio.get('/produtos', queryParameters: {'precoMaximo': 20.0, 'size': 10});
      final List<dynamic> conteudo = response.data['content'] ?? response.data;
      return conteudo.map((map) => ProdutosModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception("Erro ao buscar promoções: $e");
    }
  }

  Future<List<ProdutosModel>> buscarNecessidades() async {
    try {
      final response = await _dio.get('/produtos', queryParameters: {'size': 10});
      final List<dynamic> conteudo = response.data['content'] ?? response.data;
      return conteudo.map((map) => ProdutosModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception("Erro ao buscar necessidades: $e");
    }
  }

  Future<List<ProdutosModel>> buscarPorCategoria(String categoria) async {
    try {
      final response = await _dio.get('/produtos', queryParameters: {'categoriaMenu': categoria, 'size': 10});
      final List<dynamic> conteudo = response.data['content'] ?? response.data;
      return conteudo.map((map) => ProdutosModel.fromMap(map)).toList();
    } catch (e) {
      debugPrint("Erro ao buscar por categoria: $e");
      return [];
    }
  }

  Future<List<ProdutosModel>> buscarPorLoja(String lojaId) async {
    try {
      final response = await _dio.get('/produtos', queryParameters: {'lojaId': lojaId, 'size': 10});
      final List<dynamic> conteudo = response.data['content'] ?? response.data;
      return conteudo.map((map) => ProdutosModel.fromMap(map)).toList();
    } catch (e) {
      debugPrint("Erro ao buscar produtos da loja: $e");
      return [];
    }
  }
  Future<List<ProdutosModel>> buscarProdutosPorNome(String termo) async {
  try {
    final response = await _dio.get(
      '/produtos', 
      queryParameters: {'nome': termo, 'size': 20}
    );
    final List<dynamic> conteudo = response.data['content'] ?? response.data;
    return conteudo.map((map) => ProdutosModel.fromMap(map)).toList();
  } catch (e) {
    debugPrint("Erro ao buscar produtos: $e");
    return [];
  }
}
}