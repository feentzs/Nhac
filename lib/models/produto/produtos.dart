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
      lojaId: map['loja_id']?.toString() ?? '',
      nome: map['nome']?.toString() ?? '',
      descricao: map['descricao']?.toString() ?? '',
      preco: num.tryParse(map['preco']?.toString() ?? '0')?.toDouble() ?? 0.0,
      categoriaMenu: map['categoria_menu']?.toString() ?? '',
      imagemUrl: map['imagem_url']?.toString() ?? '',
      isAtivo: map['is_ativo'] == true,
      criadoEm: map['criado_em'] as Timestamp?,
      peso: map['peso']?.toString(),
      percentualDesconto: int.tryParse(map['percentual_desconto']?.toString() ?? '0'),
      lojaIsAberto: map['loja_is_aberto'] == true,
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