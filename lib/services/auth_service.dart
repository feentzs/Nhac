import 'package:flutter/foundation.dart';
import 'package:nhac/globals/exceptions.dart';
import 'package:nhac/services/api_client.dart';
import 'package:nhac/services/session_storage_service.dart';
import 'package:uuid/uuid.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService with ChangeNotifier {
  final _dio = ApiClient().dio;
  final _sessionStorage = SessionStorageService();

  String? _usuarioId;
  String? _nome;
  bool _carregado = false; 

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

  /// Alias de [logout] mantido pelo nome já usado em outras telas do app
  /// (ex.: `profile_content.dart`).
  Future<void> signOut() => logout();

  /// Atualiza o nome do usuário autenticado via `PATCH /usuarios/{id}`.
  /// Substitui o antigo método baseado em Firebase Auth.
  ///
  /// Importante: NÃO chama notifyListeners() aqui. Este AuthService é o
  /// `refreshListenable` do GoRouter (ver router.dart), e o redirect só
  /// depende de `isAuthenticated`/`carregado` — nada disso muda com uma
  /// troca de nome. Nenhuma tela usa `watch<AuthService>()` para mostrar o
  /// nome (isso vem do UserProvider). Disparar notifyListeners() aqui só
  /// força o GoRouter a recalcular o redirect bem no momento em que a tela
  /// de edição está chamando pop(), e essa disputa deixava o usuário preso
  /// na tela de "editar nome" mesmo com o salvamento funcionando.
  Future<void> updateUserName({required String userName}) async {
    if (_usuarioId == null) {
      throw AuthException('Utilizador não autenticado.');
    }
    try {
      await _dio.patch('/usuarios/$_usuarioId', data: {'nome': userName});
      _nome = userName;
      await _sessionStorage.salvarSessao(
        token: (await _sessionStorage.obterToken())!,
        usuarioId: _usuarioId!,
        nome: userName,
      );
    } catch (e) {
      throw mapException(e);
    }
  }

   Future<void> loginComGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      
      // Força a seleção da conta do Google (útil se o usuário tiver mais de uma)
      await googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // Se for null, o usuário fechou o pop-up nativo do Google sem logar
      if (googleUser == null) return; 

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken != null) {
        // Dispara a requisição para a rota que acabamos de criar no Spring Boot
        final response = await _dio.post('/auth/social', data: {'idToken': idToken});
        
        // Reaproveita seu método existente para salvar o JWT e o UID no SecureStorage
        await _salvarSessaoDaResposta(response.data);
      } else {
        throw AuthException('Não foi possível obter o token de autenticação do Google.');
      }
    } catch (e) {
      // O mapException já vai tratar o DioException do seu backend e erros do Firebase
      throw mapException(e);
    }
  }

  // Login/cadastro social (Google) e por telefone/SMS não são suportados
  // pelo backend atual (apenas e-mail + senha via /auth/login e /auth/registrar).
  // Todo ponto de entrada dessas opções na UI foi desabilitado (ver telas em
  // lib/pages/auth/**). Mantido como propriedades estáveis para as telas que
  // ainda checam o "tipo" de conta -- hoje toda conta é e-mail/senha.
  // TODO(backend): reabilitar quando /auth/social existir (Google, SMS, etc.)
  bool get isGoogleUser => false;
  bool get hasPassword => true;
}
