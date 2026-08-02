import 'package:flutter/material.dart';

class CadastroController extends ChangeNotifier {
  String _email = '';
  String _nome = '';
  String _telefone = '';
  String _verificationId = ''; 
  String _senha = ''; 

  String get email => _email;
  String get nome => _nome;
  String get telefone => _telefone;
  String get verificationId => _verificationId;
  String get senha => _senha; 

  void setNome(String novoNome) {
    _nome = novoNome;
    notifyListeners(); 
  }

  void setEmail(String novoEmail) {
    _email = novoEmail;
    notifyListeners();
  }

  void setSenha(String novaSenha) {
    _senha = novaSenha;
    notifyListeners();
  }

  void setTelefone(String novoTelefone) {
    _telefone = novoTelefone; 
    notifyListeners();
  }

  void setVerificationId(String value) {
    _verificationId = value;
    notifyListeners();
  }

  void limparDados() {
    _email = '';
    _nome = '';
    _telefone = '';
    _verificationId = '';
    _senha = '';
    notifyListeners();
  }
}
