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

  // Chaves para FlutterSecureStorage
  static const String secureKeyToken = 'secure_token';
  static const String secureKeyUsuarioId = 'secure_usuario_id';
  static const String secureKeyNomeUsuario = 'secure_nome_usuario';
  static const String secureKeyLoginGoogle = 'secure_login_google';
  static const String secureKeyLoginTelefone = 'secure_login_telefone';
}
