import 'package:dio/dio.dart';

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
      final data = error.response!.data as Map;
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

  if (error is AppException) return error;

  if (error.toString().contains('SocketException')) {
    return NetworkException('Sem conexão com a internet.');
  }

  return AppException('Ocorreu um erro inesperado: $error');
}
