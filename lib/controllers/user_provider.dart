import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nhac/models/usuario/usuario_model.dart';
import 'package:nhac/repository/user_repository.dart';
import 'package:nhac/services/local_cache_service.dart';

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepository = UserRepository();
  
  UsuarioModel? _usuario;
  
  StreamSubscription<UsuarioModel?>? _usuarioSubscription; 

  UsuarioModel? get usuario => _usuario;

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
      debugPrint("Iniciando upload para o usuário: ${user.uid}");
      
      final ref = FirebaseStorage.instance
          .ref()
          .child('perfil_fotos')
          .child('${user.uid}.jpg');

      debugPrint("Caminho no Storage: ${ref.fullPath}");

      TaskSnapshot snapshot = await ref.putFile(
        imagem,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      debugPrint("Upload concluído com sucesso.");

      final url = await snapshot.ref.getDownloadURL();
      debugPrint("URL obtida: $url");

      await _userRepository.atualizarDadosUsuario(user.uid, {
        'foto_url': url,
      });

      await carregarDadosUsuario();
    } catch (e) {
      debugPrint("ERRO AO SALVAR FOTO: $e");
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
