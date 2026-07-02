import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricService {
  static final _auth = LocalAuthentication();

  static Future<bool> canAuthenticate() async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> authenticate() async {
    try {
      // BUG CORRIGIDO: antes, se o aparelho não tinha biometria configurada,
      // a função retornava `true` (autenticado) sem exigir nada — ou seja,
      // "sem biometria" liberava o acesso automaticamente (fail-open).
      // Agora sempre delegamos ao local_auth, que já cai para PIN/padrão/
      // senha do aparelho por causa de `biometricOnly: false`. Só quando o
      // aparelho realmente não tem NENHUM mecanismo de bloqueio configurado
      // é que o próprio plugin retorna false, negando o acesso por padrão.
      return await _auth.authenticate(
        localizedReason: 'Autenticação necessária para acessar seus dados pessoais.',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, 
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (e) {
      debugPrint('Erro na autenticação biométrica: $e');
      return false;
    }
  }
}
