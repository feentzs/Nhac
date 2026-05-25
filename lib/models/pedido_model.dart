import 'package:cloud_firestore/cloud_firestore.dart';

class ItemPedidoModel {
  final String idProduto;
  final String nome;
  final String imagemUrl;
  final double precoHistorico; 
  final int quantidade;

  ItemPedidoModel({
    required this.idProduto,
    required this.nome,
    required this.imagemUrl,
    required this.precoHistorico,
    required this.quantidade,
  });

  factory ItemPedidoModel.fromMap(Map<String, dynamic> map) {
    return ItemPedidoModel(
      idProduto: map['idProduto'] ?? '',
      nome: map['nome'] ?? '',
      imagemUrl: map['imagemUrl'] ?? '',
      precoHistorico: (map['precoHistorico'] ?? 0).toDouble(),
      quantidade: map['quantidade'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idProduto': idProduto,
      'nome': nome,
      'imagemUrl': imagemUrl,
      'precoHistorico': precoHistorico,
      'quantidade': quantidade,
    };
  }
}

class PedidoModel {
  final String idPedido;
  final String usuarioId;
  final String lojaId;
  final List<ItemPedidoModel> itens;
  final double valorTotal;
  final double taxaFrete;
  final String formaPagamento;
  final Map<String, dynamic> enderecoEntrega; 
  final String observacao;
  final String status; 
  final Timestamp? criadoEm;

  PedidoModel({
    required this.idPedido,
    required this.usuarioId,
    required this.lojaId,
    required this.itens,
    required this.valorTotal,
    this.taxaFrete = 0.0,
    required this.formaPagamento,
    required this.enderecoEntrega,
    this.observacao = '',
    this.status = 'pendente', 
    this.criadoEm,
  });

  factory PedidoModel.fromMap(Map<String, dynamic> map, String id) {
    return PedidoModel(
      idPedido: id,
      usuarioId: map['usuarioId'] ?? '',
      lojaId: map['lojaId'] ?? '',
      itens: (map['itens'] as List<dynamic>?)
              ?.map((item) => ItemPedidoModel.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      valorTotal: (map['valorTotal'] ?? 0).toDouble(),
      taxaFrete: (map['taxaFrete'] ?? 0).toDouble(),
      formaPagamento: map['formaPagamento'] ?? '',
      enderecoEntrega: map['enderecoEntrega'] ?? {},
      observacao: map['observacao'] ?? '',
      status: map['status'] ?? 'pendente',
      criadoEm: map['criadoEm'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'usuarioId': usuarioId,
      'lojaId': lojaId,
      'itens': itens.map((item) => item.toMap()).toList(),
      'valorTotal': valorTotal,
      'taxaFrete': taxaFrete,
      'formaPagamento': formaPagamento,
      'enderecoEntrega': enderecoEntrega,
      'observacao': observacao,
      'status': status,
      'criadoEm': criadoEm ?? FieldValue.serverTimestamp(),
    };
  }
}