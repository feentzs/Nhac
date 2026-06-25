import 'package:nowa_runtime/nowa_runtime.dart';

@NowaGenerated()
class AppConstants {
  // Base URL da API REST
  static const String apiBaseUrl = 'https://backend-nhac.onrender.com/api/v1';

  // Chaves de cache local (SharedPreferences)
  static const String cacheKeyCarrinho = '@nhac_cart_items';
  static const String cacheKeyUsuario = 'cache_usuario';
  static const String cacheKeyEnderecos = 'cache_enderecos';
  static const String cacheKeyLocalizacaoGps = 'cache_localizacao_gps';
  static const String cacheKeySearchHistory = 'cache_search_history';
}
