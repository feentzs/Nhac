class UsuarioModel {
  final String id;
  final String nome;
  final String email;
  final String telefone;
  final String? imagemUrl;
  final bool ativo;

  UsuarioModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    this.imagemUrl,
    this.ativo = true,
  });

  /// True apenas se existir uma foto de perfil não-vazia.
  /// Prefira este getter a `imagemUrl!` para evitar crashes em usuários
  /// que ainda não cadastraram uma foto (estado inicial normal).
  bool get temFotoDePerfil => imagemUrl != null && imagemUrl!.isNotEmpty;

  factory UsuarioModel.fromMap(Map<String, dynamic> map) {
    return UsuarioModel(
      id: map['id']?.toString() ?? '',
      nome: map['nome']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      telefone: map['telefone']?.toString() ?? '',
      imagemUrl: map['imagemUrl']?.toString(),
      // A API deve devolver 'ativo'; se o campo não vier (respostas
      // antigas/parciais), assumimos true para não bloquear usuários
      // legítimos por ausência de dado.
      ativo: map['ativo'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'imagemUrl': imagemUrl,
      'ativo': ativo,
    };
  }
}