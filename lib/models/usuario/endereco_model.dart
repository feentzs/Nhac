class EnderecoModel {
  final String id;
  final String rua;
  final String numero;
  final String bairro;
  final String cidade;
  final String estado;
  final String cep;
  final String? complemento;
  final bool isPadrao;

  EnderecoModel({
    this.id = '',
    required this.rua,
    required this.numero,
    required this.bairro,
    required this.cidade,
    required this.estado,
    required this.cep,
    this.complemento,
    this.isPadrao = false,
  });

  EnderecoModel copyWith({
    String? id,
    String? rua,
    String? numero,
    String? bairro,
    String? cidade,
    String? estado,
    String? cep,
    String? complemento,
    bool? isPadrao,
  }) {
    return EnderecoModel(
      id: id ?? this.id,
      rua: rua ?? this.rua,
      numero: numero ?? this.numero,
      bairro: bairro ?? this.bairro,
      cidade: cidade ?? this.cidade,
      estado: estado ?? this.estado,
      cep: cep ?? this.cep,
      complemento: complemento ?? this.complemento,
      isPadrao: isPadrao ?? this.isPadrao,
    );
  }

  factory EnderecoModel.fromMap(Map<String, dynamic> map) {
    return EnderecoModel(
      id: map['id']?.toString() ?? '',
      rua: map['rua']?.toString() ?? '',
      numero: map['numero']?.toString() ?? '',
      bairro: map['bairro']?.toString() ?? '',
      cidade: map['cidade']?.toString() ?? '',
      estado: map['estado']?.toString() ?? '',
      cep: map['cep']?.toString() ?? '',
      complemento: map['complemento']?.toString(),
      isPadrao: map['isPadrao'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rua': rua,
      'numero': numero,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
      'cep': cep,
      'complemento': complemento,
      'isPadrao': isPadrao,
    };
  }
}
