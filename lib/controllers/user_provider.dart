import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nhac/models/usuario/usuario_model.dart';
import 'package:nhac/repository/user_repository.dart';
import 'package:nhac/services/local_cache_service.dart';

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth;
  final UserRepository _userRepository;

  UserProvider({FirebaseAuth? auth, UserRepository? repository})
      : _auth = auth ?? FirebaseAuth.instance,
        _userRepository = repository ?? UserRepository();
  
  UsuarioModel? _usuario;
  
  StreamSubscription<UsuarioModel?>? _usuarioSubscription; 

  UsuarioModel? get usuario => _usuario;

  bool get isGoogleUser => _auth.currentUser?.providerData.any((info) => info.providerId == 'google.com') ?? false;
  bool get hasPassword => _auth.currentUser?.providerData.any((info) => info.providerId == 'password') ?? false;

  Future<void> iniciarEscutaUsuario() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final cached = await LocalCacheService.carregarUsuario();
    if (cached != null && _usuario == null) {
      _usuario = UsuarioModel.fromMap(cached, user.uid);
      notifyListeners();
    }

    _usuarioSubscription?.cancel();
    _usuarioSubscription = _userRepository.ouvirUsuario(user.uid).listen((usuarioAtualizado) {
      _usuario = usuarioAtualizado;

      if (_usuario != null && !_usuario!.ativo) {
        _auth.signOut();
        limparUsuario();
        return;
      }

      if (_usuario != null) {
        LocalCacheService.salvarUsuario(_usuario!.toMap());
      }

      notifyListeners();
    });
  }

  Future<void> carregarDadosUsuario() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        _usuario = await _userRepository.buscarUsuario(user.uid);
        notifyListeners();
      } catch (e) {
        debugPrint("Erro ao carregar dados do usuário: $e");
      }
    }
  }

  Future<void> atualizarFotoPerfil(File imagem) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('usuarios')
          .child(user.uid)
          .child('perfil.jpg');

      await ref.putFile(
        imagem,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final url = await ref.getDownloadURL();

      await _userRepository.atualizarDadosUsuario(user.uid, {
        'foto_url': url,
      });

      await carregarDadosUsuario();
    } on FirebaseException catch (e) {
      if (e.code == 'unauthenticated') {
        debugPrint('Caminho do Storage não corresponde à regra de segurança');
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  void limparUsuario() {
    _usuario = null;
    _usuarioSubscription?.cancel();
    LocalCacheService.limparUsuario();
    notifyListeners();
  }

  @override
  void dispose() {
    _usuarioSubscription?.cancel(); 
    super.dispose();
  }
}
