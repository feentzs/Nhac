import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nhac/globals/app_constants.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio dio;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('🌍 [REQ HTTP] ${options.method} ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('✅ [RES HTTP] ${response.statusCode} ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          debugPrint('❌ [ERR HTTP] Status: ${e.response?.statusCode} | Rota: ${e.requestOptions.path}');
          if (e.response?.data != null) {
            debugPrint('Detalhes do Erro: ${e.response?.data}');
          }
          return handler.next(e);
        },
      ),
    );
  }
}
