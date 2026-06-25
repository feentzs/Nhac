class UsuarioModel {
  final String id;
  final String nome;
  final String email;
  final String telefone;
  final String? imagemUrl; 

  UsuarioModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    this.imagemUrl,
  });

  factory UsuarioModel.fromMap(Map<String, dynamic> map) {
    return UsuarioModel(
      id: map['id']?.toString() ?? '',
      nome: map['nome']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      telefone: map['telefone']?.toString() ?? '',
      imagemUrl: map['imagemUrl']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'imagemUrl': imagemUrl,
    };
  }
}