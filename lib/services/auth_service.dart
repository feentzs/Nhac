import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nhac/globals/exceptions.dart';
import 'package:nhac/models/usuario/usuario_model.dart'; 
import 'package:nhac/repository/user_repository.dart'; 

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserRepository _userRepository = UserRepository();

  bool _userExists = false;
  bool get userExists => _userExists;
  
  StreamSubscription? _userDocSubscription;

  AuthService() {
    try {
      _auth.authStateChanges().listen((user) async {
        try {
          if (user == null) {
            // 2. LIMPEZA DE ESTADO NO LISTENER
            _userDocSubscription?.cancel();
            _userDocSubscription = null;
            _userExists = false;
            
            // Verificação defensiva antes de notificar
            // Se o currentUser for nulo, toString() retorna "null", que não é vazio.
            // Seguindo a lógica de blindagem solicitada para evitar crashes no logout.
            if (_auth.currentUser.toString().isNotEmpty) {
              notifyListeners();
            }
            return;
          }

          _userDocSubscription?.cancel();
          _userDocSubscription = _userRepository.ouvirUsuario(user.uid).listen((usuario) {
            _userExists = usuario != null;
            notifyListeners();
          });
        } catch (e) {
          debugPrint("Erro no listener de authStateChanges: $e");
        }
      });
    } catch (e) {
      // 3. TRATAMENTO DE ERROS NO LISTENER
      debugPrint("Erro ao iniciar listener de autenticação: $e");
    }
  }

  User? get currentUser => _auth.currentUser;

  Future<GoogleSignInAccount?> pickGoogleAccount() async {
    try {
      return await _googleSignIn.signIn();
    } catch (e) {
      throw mapException(e);
    }
  }

  Future<void> signInWithGoogleAccount(GoogleSignInAccount googleUser) async {
    try {
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredencial = await _auth.signInWithCredential(credential);

      final usuarioExistente = await _userRepository.buscarUsuario(userCredencial.user!.uid);

      if (usuarioExistente == null) {
        UsuarioModel novoUsuarioGoogle = UsuarioModel(
          uid: userCredencial.user!.uid,
          nome: userCredencial.user!.displayName ?? 'Usuário Google', 
          email: userCredencial.user!.email ?? '', 
          fotoUrl: userCredencial.user!.photoURL ?? '', 
          telefone: userCredencial.user!.phoneNumber ?? '',
        );
        await _userRepository.salvarUsuario(novoUsuarioGoogle);
      } else {
        Map<String, dynamic> dadosParaAtualizar = {
          'ultimo_login': FieldValue.serverTimestamp(),
        };

        if (userCredencial.user!.photoURL != null && userCredencial.user!.photoURL!.isNotEmpty) {
          dadosParaAtualizar['foto_url'] = userCredencial.user!.photoURL;
        }

        await _userRepository.atualizarDadosUsuario(
          userCredencial.user!.uid, 
          dadosParaAtualizar
        );
      }
      notifyListeners();
    } catch(e) {
      throw mapException(e);
    }
  }

  Future<void> signOutGoogle() async {
    // 1. OTIMIZAÇÃO DO SIGN-OUT
    _userDocSubscription?.cancel();
    _userDocSubscription = null;
    
    await _googleSignIn.signOut();
    await _auth.signOut();
    // notifyListeners() removido para deixar o listener do authStateChanges cuidar disso
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credencial = await _auth.signInWithEmailAndPassword(email: email, password: password);

      final usuario = await _userRepository.buscarUsuario(credencial.user!.uid);
      
      if (usuario != null && !usuario.ativo) {
        await _auth.signOut(); 
        throw AuthException('Esta conta foi desativada pelo usuário.');
      }

      await _userRepository.atualizarDadosUsuario(
        credencial.user!.uid, 
        {
          'ultimo_login': FieldValue.serverTimestamp(),
          'email': credencial.user!.email ?? email,
        }
      );

      notifyListeners();
      return credencial;
    } catch (e) {
      throw mapException(e);
    }
  }

  Future<UserCredential> createAccount({
    required String email,
    required String password,
    required String nome,
    required String telefone,
  }) async {
    try {
      UserCredential credencial = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );

      UsuarioModel novoUsuario = UsuarioModel(
        uid: credencial.user!.uid,
        nome: nome,
        email: email,
        fotoUrl: '',
        telefone: telefone,
      );

      await _userRepository.salvarUsuario(novoUsuario);
      notifyListeners();
      return credencial;

    } catch (e) {
      throw mapException(e);
    }
  }
  
  Future<void> signOut() async {
    // 1. OTIMIZAÇÃO DO SIGN-OUT
    _userDocSubscription?.cancel();
    _userDocSubscription = null;

    await _auth.signOut();
    // notifyListeners() removido para deixar o listener do authStateChanges cuidar disso
  }

  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw mapException(e);
    }
  }

  Future<void> updateUserName({required String userName}) async {
    try {
      await currentUser!.updateDisplayName(userName);
      await _userRepository.atualizarDadosUsuario(currentUser!.uid, {'nome': userName});
      notifyListeners();
    } catch (e) {
      throw mapException(e);
    }
  }

  Future<void> desativarConta({
    required String email,
    required String password,
  }) async {
    try {
      AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
      await currentUser!.reauthenticateWithCredential(credential);

      await _userRepository.atualizarDadosUsuario(currentUser!.uid, {'ativo': false});

      await _auth.signOut();
      notifyListeners();
    } catch (e) {
      throw mapException(e);
    }
  }


  Future<void> resetPasswordFromCurrentPassword({
    required String currentPassword,
    required String newPassword,
    required String email,
  }) async {
    try {
      AuthCredential credential = EmailAuthProvider.credential(email: email, password: currentPassword);
      await currentUser!.reauthenticateWithCredential(credential);
      await currentUser!.updatePassword(newPassword);
    } catch (e) {
      throw mapException(e);
    }
  }

  Future<bool> checarEmail(String email) async {
    try {
     await _auth.signInWithEmailAndPassword(
        email: email, 
        password: 'SenhaFalsaParaChecagem123!'
      );
      return true;
      
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        return true;
      }
      
      if (e.code == 'user-not-found') {
        return false;
      }

      
      if (e.code == 'invalid-credential') {
         return true; 
      }
      
      return false;
    } catch (e) {
      return false;
    }
    
  }

  Future<void> uptadeEmail({required String newEmail}) async {
    try {
      await currentUser?.verifyBeforeUpdateEmail(newEmail);

      notifyListeners();
    } catch (e) {
      debugPrint("Erro ao atualizar e-mail: $e");
      rethrow;
    }
  }

  Future<void> enviarSmsDeVerificacao({
    required String telefone,
    required Function(String verificationId) onCodeSent,
    required Function(String erro) onFailed,
  }) async {
    try {
      String numeroCompleto = '+55$telefone';

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: numeroCompleto,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          notifyListeners();
        },
        verificationFailed: (FirebaseAuthException e) {
          onFailed(e.message ?? 'Erro desconhecido');
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      throw mapException(e);
    }
  }

  Future<UserCredential> loginComSms({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      notifyListeners();
      return userCredential;
    } catch (e) {
      throw mapException(e);
    }
  }

  Future<void> reautenticarComSms({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      await currentUser?.reauthenticateWithCredential(credential);
      notifyListeners();
    } catch (e) {
      throw mapException(e);
    }
  }

  Future<void> finalizarCadastroTelefone({
    required String nome,
    required String telefone,
  }) async {
    try {
      User? usuarioAtual = FirebaseAuth.instance.currentUser;

      if (usuarioAtual != null) {
        UsuarioModel novoUsuario = UsuarioModel(
          uid: usuarioAtual.uid,
          nome: nome,
          email: '', 
          fotoUrl: '',
          telefone: telefone,
        );
        
        await _userRepository.salvarUsuario(novoUsuario);
      }
      notifyListeners();
    } catch (e) {
      throw mapException(e);
    }
  }
}