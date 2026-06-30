import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nhac/models/usuario/carrinho_model.dart';

class CartRepository {
  static const String _cartKey = '@nhac_cart_items';

  Future<void> salvarCarrinhoLocal(List<CartItemModel> itens) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final String jsonString = json.encode(itens.map((i) => i.toMap()).toList());
      await prefs.setString(_cartKey, jsonString);
      
    } catch (e) {
      debugPrint("Erro ao salvar carrinho no cache local: $e");
    }
  }

  Future<List<CartItemModel>> carregarCarrinhoLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_cartKey);

      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decodedList = json.decode(jsonString);
        return decodedList.map((map) => CartItemModel.fromMap(map)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Erro ao carregar carrinho do cache: $e");
      return [];
    }
  }

  Future<void> limparCarrinho() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }
}
