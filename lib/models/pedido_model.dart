import 'package:nhac/models/usuario/endereco_model.dart';
import 'package:nhac/models/usuario/carrinho_model.dart';

class PedidoModel {
  final String? id; 
  final String usuarioId;
  final String lojaId;
  final String? lojaNome;
  final double valorTotal;
  final double taxaFrete;
  final String formaPagamento;
  final String? observacao;
  final EnderecoModel enderecoEntrega;
  final List<CartItemModel> itens;

  /// Valor em dinheiro que o cliente vai usar para pagar (para calcular o
  /// troco). Só relevante quando formaPagamento == 'Dinheiro'.
  final double? trocoPara;
  
  final String? status; 
  final String? criadoEm;
  final List<HistoricoStatusModel>? historicoStatus;

  PedidoModel({
    this.id,
    required this.usuarioId,
    required this.lojaId,
    this.lojaNome,
    required this.valorTotal,
    required this.taxaFrete,
    required this.formaPagamento,
    this.observacao,
    required this.enderecoEntrega,
    required this.itens,
    this.trocoPara,
    this.status,
    this.criadoEm,
    this.historicoStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'usuarioId': usuarioId,
      'lojaId': lojaId,
      'valorTotal': valorTotal,
      'taxaFrete': taxaFrete,
      'formaPagamento': formaPagamento,
      'observacao': observacao,
      'trocoPara': trocoPara,
      'enderecoEntrega': enderecoEntrega.toMap(), 
      'itens': itens.map((item) => item.toMap()).toList(), 
    };
  }

  factory PedidoModel.fromMap(Map<String, dynamic> map) {
    return PedidoModel(
      id: map['id'],
      usuarioId: map['usuarioId'] ?? '',
      lojaId: map['lojaId'] ?? '',
      lojaNome: map['lojaNome'],
      valorTotal: num.tryParse(map['valorTotal']?.toString() ?? '0')?.toDouble() ?? 0.0,
      taxaFrete: num.tryParse(map['taxaFrete']?.toString() ?? '0')?.toDouble() ?? 0.0,
      formaPagamento: map['formaPagamento'] ?? '',
      observacao: map['observacao'],
      trocoPara: map['trocoPara'] == null
          ? null
          : num.tryParse(map['trocoPara'].toString())?.toDouble(),
      enderecoEntrega: EnderecoModel.fromMap(map['enderecoEntrega'] ?? {}),
      itens: List<CartItemModel>.from(
        (map['itens'] ?? []).map((x) => CartItemModel.fromMap(x)),
      ),
      status: map['status'],
      criadoEm: map['criadoEm'],
      historicoStatus: map['historicoStatus'] == null
          ? null
          : List<HistoricoStatusModel>.from(
              (map['historicoStatus'] as List).map((x) => HistoricoStatusModel.fromMap(x)),
            ),
    );
  }
}

/// Uma entrada da linha do tempo do pedido (tabela
/// tb_pedidos_status_historico, já criada no banco via trigger — só falta
/// o backend expor isso em algum endpoint de leitura).
class HistoricoStatusModel {
  final String statusAnterior;
  final String statusNovo;
  final String alteradoEm;

  HistoricoStatusModel({
    required this.statusAnterior,
    required this.statusNovo,
    required this.alteradoEm,
  });

  factory HistoricoStatusModel.fromMap(Map<String, dynamic> map) {
    return HistoricoStatusModel(
      statusAnterior: map['statusAnterior'] ?? '',
      statusNovo: map['statusNovo'] ?? '',
      alteradoEm: map['alteradoEm'] ?? '',
    );
  }
}
