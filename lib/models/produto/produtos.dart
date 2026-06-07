import 'package:cloud_firestore/cloud_firestore.dart';

class ProdutosModel {
  final String uid;
  final String lojaId;          
  final String nome;
  final String descricao;
  final double preco;
  final String categoriaMenu;   
  final String imagemUrl;
  final bool isAtivo;          
  final Timestamp? criadoEm;
  final String? peso;
  final int? percentualDesconto;
  final bool lojaIsAberto;

  ProdutosModel({
    required this.uid,
    required this.lojaId,
    required this.nome,
    this.descricao = '',
    required this.preco,
    required this.categoriaMenu,
    this.imagemUrl = '',
    this.isAtivo = true,
    this.criadoEm,
    this.peso,
    this.percentualDesconto,
    this.lojaIsAberto = true,
  });

  factory ProdutosModel.fromMap(Map<String, dynamic> map, String id) {
    return ProdutosModel(
      uid: id,
      lojaId: map['loja_id'] ?? '',
      nome: map['nome'] ?? '',
      descricao: map['descricao'] ?? '',
      preco: (map['preco'] ?? 0.0).toDouble(),
      categoriaMenu: map['categoria_menu'] ?? '',
      imagemUrl: map['imagem_url'] ?? '',
      isAtivo: map['is_ativo'] ?? true,
      criadoEm: map['criado_em'] as Timestamp?,
      peso: map['peso'],
      percentualDesconto: map['percentual_desconto'],
      lojaIsAberto: map['loja_is_aberto'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'loja_id': lojaId,
      'nome': nome,
      'descricao': descricao,
      'preco': preco,
      'categoria_menu': categoriaMenu,
      'imagem_url': imagemUrl,
      'is_ativo': isAtivo,
      'criado_em': criadoEm ?? FieldValue.serverTimestamp(),
      'peso': peso,
      'percentual_desconto': percentualDesconto,
      'loja_is_aberto': lojaIsAberto,
    };
  }
}