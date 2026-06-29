import 'package:dio/dio.dart';

class ApiClient {

  static final ApiClient _instance = ApiClient._internal();

  late final Dio dio;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://backend-nhac.onrender.com/api/v1', 
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

   
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
         
          
          print('🌍 [REQ HTTP] ${options.method} ${options.uri}');
          return handler.next(options); 
        },
        onResponse: (response, handler) {

          print('✅ [RES HTTP] ${response.statusCode} ${response.requestOptions.path}');
          return handler.next(response); 
        },
        onError: (DioException e, handler) {
          print('❌ [ERR HTTP] Status: ${e.response?.statusCode} | Rota: ${e.requestOptions.path}');
          if (e.response?.data != null) {
             print('Detalhes do Erro: ${e.response?.data}');
          }
          return handler.next(e);
        },
      ),
    );
  }
}