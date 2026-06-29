import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nhac/models/usuario/usuario_model.dart';
import 'package:nhac/repositories/user_repository.dart';

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth;
  final UserRepository _userRepository;

  UserProvider({FirebaseAuth? auth, UserRepository? repository})
      : _auth = auth ?? FirebaseAuth.instance,
        _userRepository = repository ?? UserRepository();
  
  UsuarioModel? _usuario;
  bool _isLoading = false;

  UsuarioModel? get usuario => _usuario;
  bool get isLoading => _isLoading;

  bool get isGoogleUser => _auth.currentUser?.providerData.any((info) => info.providerId == 'google.com') ?? false;
  bool get hasPassword => _auth.currentUser?.providerData.any((info) => info.providerId == 'password') ?? false;

  Future<void> carregarDadosUsuario() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      _isLoading = true;
      notifyListeners(); //   <-- pode apagar se der bosta

      _usuario = await _userRepository.buscarUsuario(user.uid);
      
    } catch (e) {
      debugPrint("Erro ao carregar dados do utilizador: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> atualizarFotoPerfil(File imagem) async {
    final user = _auth.currentUser;
    final uid = user?.uid;

    if (uid == null) {
      throw Exception("Utilizador não autenticado no Provider.");
    }

    try {
      _isLoading = true;
      notifyListeners();

      final storage = FirebaseStorage.instanceFor(app: Firebase.app());
      final ref = storage.ref().child('usuarios').child(uid).child('perfil.jpg');

      await ref.putFile(
        imagem,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final url = await ref.getDownloadURL();

      await _userRepository.atualizarDadosUsuario(uid, {
        'imagemUrl': url, 
      });

      await carregarDadosUsuario();

    } catch (e) {
      debugPrint("Erro ao atualizar foto de perfil: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void limparUsuario() {
    _usuario = null;
    notifyListeners();
  }
}