class EnderecoModel {
  final String id;
  final String rua;
  final String numero;
  final String bairro;
  final String cidade;
  final String estado;
  final String cep;
  final String? complemento;
  final bool padrao;

  EnderecoModel({
    this.id = '',
    required this.rua,
    required this.numero,
    required this.bairro,
    required this.cidade,
    required this.estado,
    required this.cep,
    this.complemento,
    this.padrao = false,
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
    bool? padrao,
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
      padrao: padrao ?? this.padrao,
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
      padrao: map['padrao'] ?? false,
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
      'padrao': padrao,
    };
  }
}