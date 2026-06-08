import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nhac/models/usuario/carrinho_model.dart';
import 'package:nhac/repository/cart_repository.dart'; 

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nhac/models/produto/produtos.dart';

class CartProvider extends ChangeNotifier {
  final FirebaseAuth _auth;
  final CartRepository _cartRepository;
  final FirebaseFirestore _firestore;

  CartProvider({
    FirebaseAuth? auth, 
    CartRepository? repository,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _cartRepository = repository ?? CartRepository(),
        _firestore = firestore ?? FirebaseFirestore.instance;

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

  Future<void> adicionarItem({
    required String idProduto,
    required String nome,
    required double preco,
    required String imagemUrl,
  }) async {
    await adicionarItemComQuantidade(
      idProduto: idProduto,
      nome: nome,
      preco: preco,
      imagemUrl: imagemUrl,
      quantidade: 1,
    );
  }

  Future<void> adicionarItemComQuantidade({
    required String idProduto,
    required String nome,
    required double preco,
    required String imagemUrl,
    required int quantidade,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    String? lojaIdDoProduto;
    try {
      final doc = await _firestore.collection('produtos').doc(idProduto).get();
      if (doc.exists) {
        final produto = ProdutosModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        lojaIdDoProduto = produto.lojaId;
        if (!produto.lojaIsAberto) {
          throw Exception('A loja fechou enquanto você navegava. Não é possível adicionar este item.');
        }
      }
    } catch (e) {
      if (e.toString().contains('loja fechou')) rethrow;
      debugPrint('Erro ao verificar integridade da loja: $e');
    }

    if (_itens.isNotEmpty && lojaIdDoProduto != null) {
      final lojaAtual = _itens.values.first.lojaId;
      if (lojaAtual != lojaIdDoProduto) {
        throw Exception(
            'Você não pode adicionar itens de restaurantes diferentes no mesmo pedido. Limpe o carrinho primeiro.');
      }
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
      lojaId: lojaIdDoProduto ?? '',
      nome: nome,
      preco: preco,
      quantidade: novaQuantidade,
      imagemUrl: imagemUrl,
    );

    await _cartRepository.adicionarItemAoCarrinho(user.uid, novoItem);
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
