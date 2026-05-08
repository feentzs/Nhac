import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nhac/models/usuario/endereco_model.dart';
import 'package:nhac/repository/endereco_repository.dart';
import 'package:nhac/services/local_cache_service.dart';

class EnderecoProvider with ChangeNotifier {
  final EnderecoRepository _enderecoRepository = EnderecoRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<EnderecoModel> _enderecos = [];
  StreamSubscription<List<EnderecoModel>>? _subscription;
  bool _isLoading = false;

  List<EnderecoModel> get enderecos => _enderecos;
  bool get isLoading => _isLoading;

  Future<void> iniciarEscutaEnderecos() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // 1. Carrega do cache local imediatamente
    final cached = await LocalCacheService.carregarEnderecos();
    if (cached != null && _enderecos.isEmpty) {
      _enderecos = cached.map((m) => EnderecoModel.fromMap(m, m['id_documento'] ?? '')).toList();
      notifyListeners();
    }

    // 2. Sincroniza com Firestore em background
    _isLoading = _enderecos.isEmpty; // só mostra loading se não tem cache
    _subscription?.cancel();
    _subscription = _enderecoRepository.ouvirEnderecos(user.uid).listen((lista) {
      _enderecos = lista;
      _isLoading = false;

      // Atualiza cache com dados novos
      LocalCacheService.salvarEnderecos(
        lista.map((e) => {...e.toMap(), 'id_documento': e.idDocumento}).toList(),
      );

      notifyListeners();
    });
  }

  Future<void> definirComoPadrao(String enderecoId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    try {
      await _enderecoRepository.definirComoPadrao(user.uid, enderecoId);
    } catch (e) {
      debugPrint("Erro ao definir endereço padrão: $e");
      rethrow;
    }
  }

  Future<void> removerEndereco(String enderecoId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    try {
      await _enderecoRepository.removerEndereco(user.uid, enderecoId);
    } catch (e) {
      debugPrint("Erro ao remover endereço: $e");
      rethrow;
    }
  }

  Future<void> atualizarEndereco(EnderecoModel endereco) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      await _enderecoRepository.atualizarEndereco(user.uid, endereco);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint("Erro ao atualizar endereço: $e");
      rethrow;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> adicionarEndereco(EnderecoModel endereco) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    try {
      _isLoading = true;
      notifyListeners();
      
      await _enderecoRepository.adicionarEndereco(user.uid, endereco);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint("Erro ao adicionar endereço: $e");
      rethrow;
    }
  }
}
