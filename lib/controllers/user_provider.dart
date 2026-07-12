import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  // Login social (Google) e por telefone não são suportados pelo backend
  // atual — toda conta hoje é criada por e-mail + senha via /auth/registrar.
  // TODO(backend): reabilitar quando /auth/social existir.
  bool get isGoogleUser => false;
  bool get hasPassword => true;

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

      final storage = FirebaseStorage.instanceFor(app: Firebase.app());

      // Ver comentário equivalente em editar_foto_page.dart: o Storage
      // exige request.auth != null, mas o app não usa mais Firebase Auth
      // para login. Login anônimo satisfaz a regra sem exigir conta.
      //
      // BUG CORRIGIDO: checar só "currentUser == null" não é suficiente —
      // pode existir uma sessão anônima antiga em cache local que não é
      // mais válida no servidor (já expirada/revogada), ou o token do
      // signInAnonymously() recém-criado pode ainda não estar propagado
      // pro SDK nativo do Storage no exato momento do putFile() (corrida
      // conhecida entre firebase_auth e firebase_storage). Isso resultava
      // em "[firebase_storage/unauthenticated]" mesmo com o login anônimo
      // aparentemente OK. Forçar getIdToken(true) valida a sessão de
      // verdade contra o servidor e garante que o token está pronto antes
      // de tentar o upload.
      await _garantirSessaoAnonimaValida();

      // BUG CORRIGIDO (definitivo): o erro persistia mesmo com a sessão
      // anônima validada porque o CAMINHO usado (usuarios/{usuarioId do
      // backend}/perfil.jpg) nunca tem relação com o UID que o Firebase
      // realmente autentica no login anônimo — se as regras do Storage
      // comparam request.auth.uid com algum segmento do path (padrão
      // comum e recomendado de segurança), isso NUNCA bate, não importa
      // quão válida a sessão esteja. Em vez de depender de mudar as
      // regras no Console do Firebase, usamos o UID real da sessão como
      // parte do caminho — assim qualquer regra "auth.uid == uid" nessa
      // posição do path passa a funcionar sem tocar em nada fora do app.
      // O usuarioId do backend continua sendo a chave de tudo (é ele que
      // vai salvo em imagemUrl via API), só o CAMINHO dentro do Storage
      // muda.
      final firebaseUid = FirebaseAuth.instance.currentUser?.uid;
      if (firebaseUid == null) {
        throw Exception('Sessão do Firebase indisponível para o upload.');
      }

      debugPrint('🔍 Firebase Auth UID: $firebaseUid');
      debugPrint('🔍 usuarioId (backend, salvo via API): $usuarioId');

      final ref = storage.ref().child('usuarios_fotos').child(firebaseUid).child('perfil.jpg');

      await ref.putFile(
        imagem,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final url = await ref.getDownloadURL();

      await _userRepository.atualizarDadosUsuario(usuarioId, {
        'imagemUrl': url,
      });

      await carregarDadosUsuario();
    } on FirebaseException catch (e) {
      debugPrint("Erro ao atualizar foto de perfil: $e");
      if (e.code == 'unauthenticated' || e.code == 'unauthorized') {
        // Se persistir mesmo com o caminho agora usando o UID real da
        // sessão (usuarios_fotos/{firebaseUid}/perfil.jpg), as regras do
        // Storage exigem algo além de "UID bate com o path" — por exemplo
        // um custom claim que só contas não-anônimas têm. Nesse caso
        // precisa mesmo ajustar as regras no Console (Storage > Rules)
        // pra permitir usuários anônimos autenticados.
        throw Exception(
          'As regras de segurança do Firebase Storage estão bloqueando o '
          'upload mesmo com o caminho já usando o UID da sessão atual. '
          'Verifique em Storage > Rules no Console do Firebase se a regra '
          'permite usuários anônimos (não só contas registradas) para '
          'usuarios_fotos/{firebaseUid}/perfil.jpg.',
        );
      }
      rethrow;
    } catch (e) {
      debugPrint("Erro ao atualizar foto de perfil: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Garante que existe uma sessão anônima do Firebase Auth VÁLIDA (não só
  /// presente em cache) antes de usar o Storage. Ver comentário no local de
  /// uso para o motivo — resolve o "[firebase_storage/unauthenticated]"
  /// que ocorria mesmo com login anônimo aparentemente OK.
  Future<void> _garantirSessaoAnonimaValida() async {
    final usuarioAtual = FirebaseAuth.instance.currentUser;

    if (usuarioAtual != null) {
      try {
        // getIdToken(true) força validar contra o servidor, não só o cache
        // local. Se a sessão estiver stale/revogada, isso lança e cai no
        // catch abaixo, que faz um signInAnonymously() novo.
        await usuarioAtual.getIdToken(true);
        return;
      } catch (_) {
        // Sessão local inválida — segue pro signInAnonymously() abaixo.
      }
    }

    try {
      await FirebaseAuth.instance.signInAnonymously();
      // Força o token do login recém-feito a estar pronto antes de
      // qualquer chamada ao Storage, evitando a corrida de propagação.
      await FirebaseAuth.instance.currentUser?.getIdToken(true);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'admin-restricted-operation') {
        // Este erro específico significa que o provedor "Anônimo" está
        // desabilitado no Firebase Console (Authentication > Sign-in
        // method > Anonymous > Enable). Não é um bug de código — sem
        // habilitar isso lá, o upload de foto não tem como funcionar.
        throw Exception(
          'Configuração pendente no Firebase: habilite o provedor '
          '"Anônimo" em Authentication > Sign-in method para permitir '
          'o upload de fotos.',
        );
      }
      rethrow;
    }
  }

  void limparUsuario() {
    _usuario = null;
    notifyListeners();
  }
}
