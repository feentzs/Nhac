import 'package:nhac/models/usuario/endereco_model.dart';
import 'package:nhac/models/usuario/carrinho_model.dart';

class PedidoModel {
  final String? id; 
  final String usuarioId;
  final String lojaId;
  final double valorTotal;
  final double taxaFrete;
  final String formaPagamento;
  final double? trocoPara;
  final String? observacao;
  final String? cupomId;
  final String? cpfPagador;
  final EnderecoModel enderecoEntrega;
  final List<CartItemModel> itens;
  
  final String? status; 
  final String? criadoEm;

  PedidoModel({
    this.id,
    required this.usuarioId,
    required this.lojaId,
    required this.valorTotal,
    required this.taxaFrete,
    required this.formaPagamento,
    this.trocoPara,
    this.observacao,
    this.cupomId,
    this.cpfPagador,
    required this.enderecoEntrega,
    required this.itens,
    this.status,
    this.criadoEm,
  });

  Map<String, dynamic> toMap() {
    return {
      'lojaId': lojaId,
      'formaPagamento': formaPagamento,
      if (trocoPara != null) 'trocoPara': trocoPara,
      if (observacao != null && observacao!.isNotEmpty) 'observacao': observacao,
      if (cupomId != null) 'cupomId': cupomId,
      if (cpfPagador != null) 'cpfPagador': cpfPagador,
      'enderecoEntrega': {
        'rua': enderecoEntrega.rua,
        'numero': enderecoEntrega.numero,
        'bairro': enderecoEntrega.bairro,
        'cidade': enderecoEntrega.cidade,
        'estado': enderecoEntrega.estado,
        'cep': enderecoEntrega.cep,
        if (enderecoEntrega.complemento != null && enderecoEntrega.complemento!.isNotEmpty) 
          'complemento': enderecoEntrega.complemento,
      },
      'itens': itens.map((item) => {
        'produtoId': item.produtoId,
        'nome': item.nome,
        if (item.imagemUrl.isNotEmpty) 'imagemUrl': item.imagemUrl,
        'quantidade': item.quantidade,
      }).toList(),
    };
  }

  factory PedidoModel.fromMap(Map<String, dynamic> map) {
    return PedidoModel(
      id: map['id'],
      usuarioId: map['usuarioId'] ?? '',
      lojaId: map['lojaId'] ?? '',
      valorTotal: num.tryParse(map['valorTotal']?.toString() ?? '0')?.toDouble() ?? 0.0,
      taxaFrete: num.tryParse(map['taxaFrete']?.toString() ?? '0')?.toDouble() ?? 0.0,
      formaPagamento: map['formaPagamento'] ?? '',
      trocoPara: num.tryParse(map['trocoPara']?.toString() ?? '0')?.toDouble(),
      observacao: map['observacao'],
      cupomId: map['cupomId'],
      cpfPagador: map['cpfPagador'],
      enderecoEntrega: EnderecoModel.fromMap(map['enderecoEntrega'] ?? {}),
      itens: List<CartItemModel>.from(
        (map['itens'] ?? []).map((x) => CartItemModel.fromMap(x)),
      ),
      status: map['status'],
      criadoEm: map['criadoEm'],
    );
  }
}
