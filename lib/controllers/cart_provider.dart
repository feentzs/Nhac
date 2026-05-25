import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nhac/models/usuario/carrinho_model.dart';
import 'package:nhac/repository/cart_repository.dart'; 

class CartProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CartRepository _cartRepository = CartRepository();

  final Map<String, CarrinhoModel> _itens = {};
  StreamSubscription<List<CarrinhoModel>>? _carrinhoSubscription;

  double _valorTotal = 0.0;
  int _totalDeUnidades = 0;

  Map<String, CarrinhoModel> get itens => _itens;
  int get quantidadeItens => _itens.length;

  double get valorTotal => _valorTotal;
  int get totalDeUnidades => _totalDeUnidades;

  String _observacao = '';
  String get observacao => _observacao;

  String? get lojaIdAtual {
    if (_itens.isEmpty) return null;
    return _itens.values.first.lojaId;
  }

  void setObservacao(String texto) {
    if (_observacao != texto) {
      _observacao = texto;
      notifyListeners();
    }
  }

  void limparCarrinhoLocal() {
    _itens.clear();
    _valorTotal = 0.0;
    _totalDeUnidades = 0;
    _observacao = '';          
    _carrinhoSubscription?.cancel();
    notifyListeners();
  }

  void iniciarEscutaCarrinho() {
    final user = _auth.currentUser;
    
    if (user != null) {
      _carrinhoSubscription?.cancel();
      
      _carrinhoSubscription = _cartRepository.ouvirCarrinho(user.uid).listen((listaItensFirebase) {
        _itens.clear();
        _valorTotal = 0.0;
        _totalDeUnidades = 0;
        
        for (var item in listaItensFirebase) {
          _itens[item.idProduto] = item;
          _valorTotal += item.preco * item.quantidade;
          _totalDeUnidades += item.quantidade;
        }
        
        notifyListeners();
      });
    }
  }

  Future<bool> adicionarItem({
    required String idProduto,
    required String nome,
    required double preco,
    required String imagemUrl,
    required String lojaId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    if (_itens.isNotEmpty && lojaIdAtual != null && lojaIdAtual != lojaId) {
      return false;
    }

    int novaQuantidade = 1;
    if (_itens.containsKey(idProduto)) {
      novaQuantidade = _itens[idProduto]!.quantidade + 1;
    }

    final novoItem = CarrinhoModel(
      idDocumento: idProduto, 
      idProduto: idProduto,
      nome: nome,
      preco: preco,
      quantidade: novaQuantidade,
      imagemUrl: imagemUrl,
      lojaId: lojaId, 
    );

    await _cartRepository.adicionarItemAoCarrinho(user.uid, novoItem);
    return true; // ✅ Sucesso
  }

  Future<bool> adicionarItemComQuantidade({
    required String idProduto,
    required String nome,
    required double preco,
    required String imagemUrl,
    required int quantidade,
    required String lojaId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    if (_itens.isNotEmpty && lojaIdAtual != null && lojaIdAtual != lojaId) {
      return false; 
    }

    final int novaQuantidade;
    if (_itens.containsKey(idProduto)) {
      novaQuantidade = _itens[idProduto]!.quantidade + quantidade;
    } else {
      novaQuantidade = quantidade;
    }

    final novoItem = CarrinhoModel(
      idDocumento: idProduto,
      idProduto: idProduto,
      nome: nome,
      preco: preco,
      quantidade: novaQuantidade,
      imagemUrl: imagemUrl,
      lojaId: lojaId,
    );

    await _cartRepository.adicionarItemAoCarrinho(user.uid, novoItem);
    return true;
  }

  Future<void> removerItem(String idProduto) async {
    final user = _auth.currentUser;
    if (user == null || !_itens.containsKey(idProduto)) return;

    if (_itens[idProduto]!.quantidade > 1) {
      final itemAtualizado = _itens[idProduto]!.copyWith(
        quantidade: _itens[idProduto]!.quantidade - 1,
      );
      await _cartRepository.adicionarItemAoCarrinho(user.uid, itemAtualizado);
    } else {
      await _cartRepository.removerItemDoCarrinho(user.uid, idProduto);
    }
  }

  Future<void> excluirItemDoCarrinho(String idProduto) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _cartRepository.removerItemDoCarrinho(user.uid, idProduto);
  }

  Future<void> esvaziarCarrinho() async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    await _cartRepository.esvaziarCarrinho(user.uid);
    _observacao = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _carrinhoSubscription?.cancel();
    super.dispose();
  }
}