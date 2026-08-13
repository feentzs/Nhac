/// Utilitários para normalizar dados de endereço antes de enviar para o
/// backend, que exige: estado com exatamente 2 caracteres (UF), além de
/// número e cidade obrigatórios.
class EnderecoUtils {
  EnderecoUtils._();

  /// Mapa nome completo do estado -> sigla (UF).
  /// Necessário porque o pacote `geocoding` (usado na geolocalização por
  /// GPS) retorna o `administrativeArea` como nome completo
  /// (ex: "São Paulo"), e não como sigla (ex: "SP"), diferente do Google
  /// Places, que já retorna a sigla via `short_name`.
  static const Map<String, String> _nomeParaUf = {
    'acre': 'AC',
    'alagoas': 'AL',
    'amapa': 'AP',
    'amazonas': 'AM',
    'bahia': 'BA',
    'ceara': 'CE',
    'distrito federal': 'DF',
    'espirito santo': 'ES',
    'goias': 'GO',
    'maranhao': 'MA',
    'mato grosso': 'MT',
    'mato grosso do sul': 'MS',
    'minas gerais': 'MG',
    'para': 'PA',
    'paraiba': 'PB',
    'parana': 'PR',
    'pernambuco': 'PE',
    'piaui': 'PI',
    'rio de janeiro': 'RJ',
    'rio grande do norte': 'RN',
    'rio grande do sul': 'RS',
    'rondonia': 'RO',
    'roraima': 'RR',
    'santa catarina': 'SC',
    'sao paulo': 'SP',
    'sergipe': 'SE',
    'tocantins': 'TO',
  };

  static String _semAcentos(String texto) {
    const comAcento = 'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ';
    const semAcento = 'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC';
    var resultado = texto;
    for (var i = 0; i < comAcento.length; i++) {
      resultado = resultado.replaceAll(comAcento[i], semAcento[i]);
    }
    return resultado;
  }

  /// Converte o estado recebido (sigla ou nome completo) para a sigla de
  /// 2 caracteres exigida pelo backend. Retorna string vazia se não
  /// conseguir identificar.
  static String normalizarEstado(String? estado) {
    if (estado == null || estado.trim().isEmpty) return '';
    final valor = estado.trim();

    // Já é uma sigla válida (ex: "SP").
    if (valor.length == 2) return valor.toUpperCase();

    final chave = _semAcentos(valor.toLowerCase()).trim();
    return _nomeParaUf[chave] ?? '';
  }

  /// Garante que o número não seja enviado vazio para o backend.
  static String normalizarNumero(String? numero) {
    if (numero == null || numero.trim().isEmpty) return 'S/N';
    return numero.trim();
  }

  /// Escolhe a melhor cidade disponível entre possíveis fontes
  /// (ex: locality do GPS/Places, subAdministrativeArea como fallback).
  static String normalizarCidade(List<String?> candidatos) {
    for (final c in candidatos) {
      if (c != null && c.trim().isNotEmpty) return c.trim();
    }
    return '';
  }

  /// Retorna true se o endereço tem os campos mínimos exigidos pelo
  /// backend (cidade, estado com 2 caracteres e número).
  static bool ehValido({
    required String cidade,
    required String estado,
    required String numero,
  }) {
    return cidade.trim().isNotEmpty &&
        estado.trim().length == 2 &&
        numero.trim().isNotEmpty;
  }
}
