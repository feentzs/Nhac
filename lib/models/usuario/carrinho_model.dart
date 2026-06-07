class CarrinhoModel {
  final String idDocumento;
  final String idProduto;
  final String lojaId;
  final String imagemUrl;
  final String nome;
  final double preco;
  final int quantidade;

  CarrinhoModel({
    required this.idDocumento,
    required this.idProduto,
    required this.lojaId,
    required this.imagemUrl,
    required this.nome,
    required this.preco,
    required this.quantidade,
  });


  factory CarrinhoModel.fromMap(Map<String, dynamic> map, String docId){
    return CarrinhoModel(
      idDocumento: docId,
      idProduto: map['id_produto'] ?? '',
      lojaId: map['loja_id'] ?? '',
      imagemUrl: map['imagem_url'] ?? '',
      nome: map['nome'] ?? '',
      preco: num.tryParse(map['preco']?.toString() ?? '0')?.toDouble() ?? 0.0,
      quantidade: int.tryParse(map['quantidade']?.toString() ?? '0') ?? 0,
    );
  }

  CarrinhoModel copyWith({
    String? idDocumento,
    String? idProduto,
    String? lojaId,
    String? imagemUrl,
    String? nome,
    double? preco,
    int? quantidade,
  }) =>
      CarrinhoModel(
        idDocumento: idDocumento ?? this.idDocumento,
        idProduto: idProduto ?? this.idProduto,
        lojaId: lojaId ?? this.lojaId,
        imagemUrl: imagemUrl ?? this.imagemUrl,
        nome: nome ?? this.nome,
        preco: preco ?? this.preco,
        quantidade: quantidade ?? this.quantidade,
      );

  Map<String, dynamic> toMap(){
    return {
      'id_produto': idProduto,
      'loja_id': lojaId,
      'imagem_url': imagemUrl,
      'nome': nome,
      'preco': preco,
      'quantidade': quantidade,
    };
  }
}