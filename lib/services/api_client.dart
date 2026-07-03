import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nhac/globals/app_constants.dart';
import 'package:nhac/services/session_storage_service.dart';

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
        // Render free tier "dorme" após inatividade — o primeiro request
        // após esse período pode levar 50-60s até o serviço acordar.
        // 40s era curto demais e causava timeout intermitente sem motivo
        // aparente. 70s dá folga pro cold-start sem travar o app pra sempre
        // em caso de falha de rede real.
        connectTimeout: const Duration(seconds: 70),
        receiveTimeout: const Duration(seconds: 70),
        sendTimeout: const Duration(seconds: 70),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SessionStorageService().obterToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          debugPrint('🌍 [REQ HTTP] ${options.method} ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('✅ [RES HTTP] ${response.statusCode} ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          debugPrint('❌ [ERR HTTP] Status: ${e.response?.statusCode} | Rota: ${e.requestOptions.path}');
          
          if (e.response?.statusCode == 401) {
             await SessionStorageService().limparSessao();
          }

          if (e.response?.data != null) {
            debugPrint('Detalhes do Erro: ${e.response?.data}');
          }
          return handler.next(e);
        },
      ),
    );
  }
}
