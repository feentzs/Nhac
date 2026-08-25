import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nhac/globals/router.dart';
import 'package:nhac/models/usuario/usuario_model.dart';
import 'package:nhac/repositories/user_repository.dart';
import 'package:nhac/services/auth_service.dart';

class UserProvider with ChangeNotifier {
  final AuthService _authService;
  final UserRepository _userRepository;

  UserProvider({AuthService? authService, UserRepository? repository})
      : _authService = authService ?? authServiceRoteador,
        _userRepository = repository ?? UserRepository();

  UsuarioModel? _usuario;
  bool _isLoading = false;

  UsuarioModel? get usuario => _usuario;
  bool get isLoading => _isLoading;

  
  bool get isGoogleUser => _authService.isGoogleUser;
  bool get hasPassword => !isGoogleUser;

  Future<void> carregarDadosUsuario() async {
    final usuarioId = _authService.usuarioId;
    if (usuarioId == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      _usuario = await _userRepository.buscarUsuario(usuarioId);
    } catch (e) {
      debugPrint("Erro ao carregar dados do utilizador: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> atualizarFotoPerfil(File imagem) async {
    final usuarioId = _authService.usuarioId;

    if (usuarioId == null) {
      throw Exception("Utilizador não autenticado no Provider.");
    }

    try {
      _isLoading = true;
      notifyListeners();

      final url = await _userRepository.uploadFotoPerfil(usuarioId, imagem.path);
      
      await _userRepository.atualizarDadosUsuario(usuarioId, {
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
