import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() => message;
}

class AuthException extends AppException {
  AuthException(super.message, {super.code});
}

class NetworkException extends AppException {
  NetworkException(super.message);
}

AppException mapException(Object error) {
  if (error is DioException) {
    if (error.response?.data != null && error.response!.data is Map) {
      final data = error.response!.data as Map<String, dynamic>;
      if (data.containsKey('message')) {
        return AppException(data['message'].toString());
      }
    }
    
    if (error.response?.statusCode == 401) {
      return AuthException('Sessão expirada. Faça login novamente.');
    }
    
    if (error.type == DioExceptionType.connectionTimeout || 
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return NetworkException('Sem conexão com a internet.');
    }
    
    return AppException('Ocorreu um erro no servidor: ${error.response?.statusCode ?? error.message}');
  }

  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'user-not-found':
        return AuthException('Usuário não encontrado.');
      case 'wrong-password':
        return AuthException('Senha incorreta.');
      case 'email-already-in-use':
        return AuthException('Este e-mail já está em uso por outra conta.');
      case 'invalid-email':
        return AuthException('E-mail inválido.');
      case 'weak-password':
        return AuthException('A senha deve ter no mínimo 6 caracteres.');
      case 'user-disabled':
        return AuthException('Esta conta foi desativada.');
      case 'operation-not-allowed':
        return AuthException('Operação não permitida pelo servidor.');
      case 'account-exists-with-different-credential':
        return AuthException('Este e-mail já está associado a outra conta.');
      case 'invalid-credential':
        return AuthException('Credenciais inválidas. Tente novamente.');
      default:
        return AuthException(error.message ?? 'Erro na autenticação.');
    }
  }

  if (error is AppException) return error;

  if (error.toString().contains('SocketException')) {
    return NetworkException('Sem conexão com a internet.');
  }

  return AppException('Ocorreu um erro inesperado: $error');
}
