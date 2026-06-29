class MetodosPagamentoModel {
  final String id;
  final String bandeira;
  final String? criadoEm;
  final String nomeCartao;
  final bool padrao;
  final String tipo;
  final String ultimosDigitos;

  MetodosPagamentoModel({
    required this.id,
    required this.bandeira,
    this.criadoEm,
    required this.nomeCartao,
    this.padrao = false,
    required this.tipo,
    required this.ultimosDigitos,
  });

  factory MetodosPagamentoModel.fromMap(Map<String, dynamic> map, String docId) {
    return MetodosPagamentoModel(
      id: docId,
      bandeira: map['bandeira'] ?? '',
      criadoEm: map['criadoEm']?.toString(), 
      nomeCartao: map['nomeCartao'] ?? '',
      padrao: map['padrao'] ?? false,
      tipo: map['tipo'] ?? '',
      ultimosDigitos: map['ultimosDigitos'] ?? '',
    );
  }

  MetodosPagamentoModel copyWith({
    String? id,
    String? bandeira,
    String? criadoEm,
    String? nomeCartao,
    bool? padrao,
    String? tipo,
    String? ultimosDigitos,
  }) =>
      MetodosPagamentoModel(
        id: id ?? this.id,
        bandeira: bandeira ?? this.bandeira,
        criadoEm: criadoEm ?? this.criadoEm,
        nomeCartao: nomeCartao ?? this.nomeCartao,
        padrao: padrao ?? this.padrao,
        tipo: tipo ?? this.tipo,
        ultimosDigitos: ultimosDigitos ?? this.ultimosDigitos,
      );

  Map<String, dynamic> toMap() {
    return {
      'bandeira': bandeira,
      'criadoEm': criadoEm ?? DateTime.now().toIso8601String(),
      'nomeCartao': nomeCartao,
      'padrao': padrao,
      'tipo': tipo,
      'ultimosDigitos': ultimosDigitos,
    };
  }
}