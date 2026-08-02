import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nhac/globals/app_constants.dart';

class SessionStorageService {
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  Future<void> salvarSessao({
    required String token,
    required String usuarioId,
    required String nome,
  }) async {
    await _storage.write(key: AppConstants.secureKeyToken, value: token);
    await _storage.write(key: AppConstants.secureKeyUsuarioId, value: usuarioId);
    await _storage.write(key: AppConstants.secureKeyNomeUsuario, value: nome);
  }

  Future<String?> obterToken() async {
    return await _storage.read(key: AppConstants.secureKeyToken);
  }

  Future<String?> obterUsuarioId() async {
    return await _storage.read(key: AppConstants.secureKeyUsuarioId);
  }

  Future<String?> obterNome() async {
    return await _storage.read(key: AppConstants.secureKeyNomeUsuario);
  }

  Future<void> limparSessao() async {
    await _storage.delete(key: AppConstants.secureKeyToken);
    await _storage.delete(key: AppConstants.secureKeyUsuarioId);
    await _storage.delete(key: AppConstants.secureKeyNomeUsuario);
  }
}
