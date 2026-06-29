class FavoritosModel {
  final String id;
  final String produtoId;
  final String imagemUrl;
  final String nome;
  final double preco;

  FavoritosModel({
    required this.id,
    required this.produtoId,
    required this.imagemUrl,
    required this.nome,
    required this.preco,
  });

  factory FavoritosModel.fromMap(Map<String, dynamic> map, String docId){
    return FavoritosModel(
      id: docId,
      produtoId: map['produtoId'] ?? '',
      imagemUrl: map['imagemUrl'] ?? '',
      nome: map['nome'] ?? '',
      preco: (map['preco'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap(){
    return {
      'produtoId': produtoId,
      'imagemUrl': imagemUrl,
      'nome': nome,
      'preco': preco,
    };
  }
  FavoritosModel copyWith({
    String? id,
    String? produtoId,
    String? imagemUrl,
    String? nome,
    double? preco,
  }) => FavoritosModel(
    id: id ?? this.id,
    produtoId: produtoId ?? this.produtoId,
    imagemUrl: imagemUrl ?? this.imagemUrl,
    nome: nome ?? this.nome,
    preco: preco ?? this.preco,
  );

}