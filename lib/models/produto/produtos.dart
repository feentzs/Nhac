class ProdutosModel {
  final String id;
  final String nome;
  final String descricao;
  final double preco;
  final String categoriaMenu;    
  final String imagemUrl;   
  final int percentualDesconto;
  final String lojaId;
  final String lojaNome;
  // BUG CORRIGIDO: produtos de lojas fechadas apareciam na Home/busca
  // podendo ser adicionados direto pelo "+" sem o usuário nunca ver que a
  // loja estava fechada — nada informava esse status por produto antes.
  final bool lojaAberta;

  ProdutosModel({
    required this.id,
    required this.nome,
    this.descricao = '',
    required this.preco,
    required this.categoriaMenu,
    this.imagemUrl = '',
    this.percentualDesconto = 0,
    this.lojaId = '',
    this.lojaNome = '',
    this.lojaAberta = true,
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
      lojaId: map['lojaId']?.toString() ?? '',
      lojaNome: map['lojaNome']?.toString() ?? '',
      lojaAberta: map['lojaAberta'] ?? true,
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
      'lojaId': lojaId,
      'lojaNome': lojaNome,
      'lojaAberta': lojaAberta,
    };
  }
}
