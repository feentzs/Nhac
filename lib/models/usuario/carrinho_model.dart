class CarrinhoModel {
  final String idDocumento;
  final String idProduto;
  final String imagemUrl;
  final String nome;
  final double preco;
  final int quantidade;
  final String lojaId; 

  CarrinhoModel({
    required this.idDocumento,
    required this.idProduto,
    required this.imagemUrl,
    required this.nome,
    required this.preco,
    required this.quantidade,
    required this.lojaId, 
  });

  factory CarrinhoModel.fromMap(Map<String, dynamic> map, String docId){
    return CarrinhoModel(
      idDocumento: docId,
      idProduto: map['id_produto'] ?? '',
      imagemUrl: map['imagem_url'] ?? '',
      nome: map['nome'] ?? '',
      preco: map['preco']?.toDouble() ?? 0.0,
      quantidade: map['quantidade'] ?? 0,
      lojaId: map['loja_id'] ?? '', 
    );
  }

  CarrinhoModel copyWith({
    String? idDocumento,
    String? idProduto,
    String? imagemUrl,
    String? nome,
    double? preco,
    int? quantidade,
    String? lojaId, 
  }) =>
      CarrinhoModel(
        idDocumento: idDocumento ?? this.idDocumento,
        idProduto: idProduto ?? this.idProduto,
        imagemUrl: imagemUrl ?? this.imagemUrl,
        nome: nome ?? this.nome,
        preco: preco ?? this.preco,
        quantidade: quantidade ?? this.quantidade,
        lojaId: lojaId ?? this.lojaId,
      );

  Map<String, dynamic> toMap(){
    return {
      'id_produto': idProduto,
      'imagem_url': imagemUrl,
      'nome': nome,
      'preco': preco,
      'quantidade': quantidade,
      'loja_id': lojaId, 
    };
  }
}