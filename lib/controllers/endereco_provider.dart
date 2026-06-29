import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nhac/models/usuario/endereco_model.dart';
import 'package:nhac/repositories/endereco_repository.dart';

class EnderecoProvider with ChangeNotifier {
  final EnderecoRepository _enderecoRepository;
  final FirebaseAuth _auth;

  EnderecoProvider({FirebaseAuth? auth, EnderecoRepository? repository})
      : _auth = auth ?? FirebaseAuth.instance,
        _enderecoRepository = repository ?? EnderecoRepository();

  List<EnderecoModel> _enderecos = [];
  bool _isLoading = false;

  List<EnderecoModel> get enderecos => _enderecos;
  bool get isLoading => _isLoading;

  Future<void> buscarEnderecos() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      _enderecos = await _enderecoRepository.buscarEnderecos(user.uid);
    } catch (e) {
      debugPrint("Erro ao buscar endereços: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> adicionarEndereco(EnderecoModel endereco) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    try {
      _isLoading = true;
      notifyListeners();
      
      await _enderecoRepository.adicionarEndereco(user.uid, endereco);
      await buscarEnderecos(); 
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint("Erro ao adicionar endereço: $e");
      rethrow;
    }
  }

  Future<void> removerEndereco(String enderecoId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    try {
      _isLoading = true;
      notifyListeners();

      await _enderecoRepository.removerEndereco(user.uid, enderecoId);
      await buscarEnderecos();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint("Erro ao remover endereço: $e");
      rethrow;
    }
  }

  Future<void> atualizarEndereco(String enderecoId, EnderecoModel endereco) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      await _enderecoRepository.atualizarEndereco(user.uid, enderecoId, endereco);
      await buscarEnderecos();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint("Erro ao atualizar endereço: $e");
      rethrow;
    }
  }

  // Função restaurada!
  Future<void> definirComoPadrao(String enderecoId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final enderecoSelecionado = _enderecos.firstWhere((e) => e.id == enderecoId);

      await _enderecoRepository.atualizarEndereco(
        user.uid, 
        enderecoId, 
        enderecoSelecionado.copyWith(padrao: true)
      );

      await buscarEnderecos();
    } catch (e) {
      debugPrint("Erro ao definir como padrão: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}