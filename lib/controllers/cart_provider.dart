import 'package:flutter/material.dart';
import 'package:nhac/models/usuario/carrinho_model.dart';
import 'package:nhac/repositories/cart_repository.dart';

class CartProvider extends ChangeNotifier {
  final CartRepository _cartRepository;

  CartProvider({CartRepository? repository}) 
      : _cartRepository = repository ?? CartRepository();

  Map<String, CartItemModel> _itens = {};
  
  double _valorTotal = 0.0;
  int _totalDeUnidades = 0;
  String _observacao = '';

  Map<String, CartItemModel> get itens => _itens;
  int get quantidadeItens => _itens.length;
  double get valorTotal => _valorTotal;
  int get totalDeUnidades => _totalDeUnidades;
  String get observacao => _observacao;

  Future<void> carregarCarrinhoLocal() async {
    final listaSalva = await _cartRepository.carregarCarrinhoLocal();
    _itens = { for (var item in listaSalva) item.produtoId : item };
    _recalcularTotais();
  }

  void setObservacao(String texto) {
    if (_observacao != texto) {
      _observacao = texto;
      notifyListeners();
    }
  }

  Future<void> adicionarItemComQuantidade({
    required String idProduto,
    required String nome,
    required double preco,
    required String imagemUrl,
    required int quantidade,
  }) async {
    
    
    if (_itens.containsKey(idProduto)) {
      _itens[idProduto]!.quantidade += quantidade;
    } else {
      _itens[idProduto] = CartItemModel(
        produtoId: idProduto,
        nome: nome,
        imagemUrl: imagemUrl,
        preco: preco,
        quantidade: quantidade,
      );
    }

    _recalcularTotais();
    await _cartRepository.salvarCarrinhoLocal(_itens.values.toList());
  }

  Future<void> removerItem(String idProduto) async {
    if (!_itens.containsKey(idProduto)) return;

    if (_itens[idProduto]!.quantidade > 1) {
      _itens[idProduto]!.quantidade -= 1;
    } else {
      _itens.remove(idProduto);
    }

    _recalcularTotais();
    await _cartRepository.salvarCarrinhoLocal(_itens.values.toList());
  }

  Future<void> excluirItemDoCarrinho(String idProduto) async {
    _itens.remove(idProduto);
    _recalcularTotais();
    await _cartRepository.salvarCarrinhoLocal(_itens.values.toList());
  }

  Future<void> esvaziarCarrinho() async {
    _itens.clear();
    _observacao = '';
    _recalcularTotais();
    await _cartRepository.limparCarrinho();
  }

  void _recalcularTotais() {
    _valorTotal = 0.0;
    _totalDeUnidades = 0;
    
    _itens.forEach((key, item) {
      _valorTotal += item.preco * item.quantidade;
      _totalDeUnidades += item.quantidade;
    });
    
    notifyListeners();
  }
}