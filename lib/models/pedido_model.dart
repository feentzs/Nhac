import 'package:nhac/models/usuario/endereco_model.dart';
import 'package:nhac/models/usuario/carrinho_model.dart';

class PedidoModel {
  final String? id; 
  final String usuarioId;
  final String lojaId;
  final double valorTotal;
  final double taxaFrete;
  final String formaPagamento;
  final String? observacao;
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
    this.observacao,
    required this.enderecoEntrega,
    required this.itens,
    this.status,
    this.criadoEm,
  });

  Map<String, dynamic> toMap() {
    return {
      'usuarioId': usuarioId,
      'lojaId': lojaId,
      'valorTotal': valorTotal,
      'taxaFrete': taxaFrete,
      'formaPagamento': formaPagamento,
      'observacao': observacao,
      'enderecoEntrega': enderecoEntrega.toMap(), 
      'itens': itens.map((item) => item.toMap()).toList(), 
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
      observacao: map['observacao'],
      enderecoEntrega: EnderecoModel.fromMap(map['enderecoEntrega'] ?? {}),
      itens: List<CartItemModel>.from(
        (map['itens'] ?? []).map((x) => CartItemModel.fromMap(x)),
      ),
      status: map['status'],
      criadoEm: map['criadoEm'],
    );
  }
}