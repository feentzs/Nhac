class ProdutosModel {
  final String id;
  final String nome;
  final String descricao;
  final double preco;
  final String categoriaMenu;    
  final String imagemUrl;   
  final int percentualDesconto;

  ProdutosModel({
    required this.id,
    required this.nome,
    this.descricao = '',
    required this.preco,
    required this.categoriaMenu,
    this.imagemUrl = '',
    this.percentualDesconto = 0,
  });

  factory ProdutosModel.fromMap(Map<String, dynamic> map) {
    return ProdutosModel(
      id: map['id']?.toString() ?? '',
      nome: map['nome']?.toString() ?? '',
      descricao: map['descricao']?.toString() ?? '',
      preco: num.tryParse(map['preco']?.toString() ?? '0')?.toDouble() ?? 0.0,
      categoriaMenu: map['categoriaMenu']?.toString() ?? '',
      imagemUrl: map['imagemUrl']?.toString() ?? '',
      percentualDesconto: map['percentualDesconto'] ?? 0,
    );
  }

  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'categoriaMenu': categoriaMenu,
      'imagemUrl': imagemUrl,
      'percentualDesconto': percentualDesconto,
    };
  }
}