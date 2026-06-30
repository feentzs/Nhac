import 'package:flutter/foundation.dart';
import 'package:nhac/globals/exceptions.dart';
import 'package:nhac/services/api_client.dart';
import 'package:nhac/services/session_storage_service.dart';
import 'package:uuid/uuid.dart';

class AuthService with ChangeNotifier {
  final _dio = ApiClient().dio;
  final _sessionStorage = SessionStorageService();

  String? _usuarioId;
  String? _nome;
  bool _carregado = false; // true assim que a sessão local já foi lida do storage

  bool get isAuthenticated => _usuarioId != null;
  bool get carregado => _carregado;
  String? get usuarioId => _usuarioId;
  String? get nome => _nome;

  AuthService() {
    _carregarSessaoLocal();
  }

  Future<void> _carregarSessaoLocal() async {
    _usuarioId = await _sessionStorage.obterUsuarioId();
    _nome = await _sessionStorage.obterNome();
    _carregado = true;
    notifyListeners();
  }

  Future<void> login({required String email, required String senha}) async {
    try {
      final response = await _dio.post('/auth/login', data: {'email': email, 'senha': senha});
      await _salvarSessaoDaResposta(response.data);
    } catch (e) {
      // 401 (corpo vazio) e 500 (email não encontrado) devem virar a MESMA mensagem
      // genérica para o usuário -- é uma inconsistência conhecida do backend.
      throw AuthException('E-mail ou senha inválidos.');
    }
  }

  Future<void> registrar({
    required String nome,
    required String email,
    required String telefone,
    required String senha,
  }) async {
    try {
      final id = const Uuid().v4();
      final response = await _dio.post('/auth/registrar', data: {
        'id': id, 'nome': nome, 'email': email, 'telefone': telefone, 'senha': senha,
      });
      await _salvarSessaoDaResposta(response.data);
    } catch (e) {
      throw mapException(e);
    }
  }

  Future<void> _salvarSessaoDaResposta(Map<String, dynamic> data) async {
    final token = data['token'] as String;
    final usuarioId = data['usuarioId'] as String;
    final nome = data['nome'] as String;
    await _sessionStorage.salvarSessao(token: token, usuarioId: usuarioId, nome: nome);
    _usuarioId = usuarioId;
    _nome = nome;
    notifyListeners();
  }

  Future<void> logout() async {
    await _sessionStorage.limparSessao();
    _usuarioId = null;
    _nome = null;
    notifyListeners();
  }

  // TODO(backend): reabilitar quando /auth/social existir (Google, SMS, etc.)
}
