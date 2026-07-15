/// Modelo de avaliação de pedido/loja. Corresponde à tabela tb_avaliacoes
/// já criada no banco (com triggers que recalculam automaticamente
/// tb_lojas.avaliacao_media/total_avaliacoes) — só falta o backend expor
/// isso via endpoint (POST /avaliacoes).
class AvaliacaoModel {
  final String pedidoId;
  final String lojaId;
  final int nota; // 1 a 5
  final String? comentario;

  AvaliacaoModel({
    required this.pedidoId,
    required this.lojaId,
    required this.nota,
    this.comentario,
  });

  Map<String, dynamic> toMap() {
    return {
      'pedidoId': pedidoId,
      'lojaId': lojaId,
      'nota': nota,
      'comentario': comentario,
    };
  }
}
