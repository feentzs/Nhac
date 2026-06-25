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
      final isSupported = await canAuthenticate();
      
      if (!isSupported) {
       
        return true; 
      }

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
