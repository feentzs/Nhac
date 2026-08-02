import 'package:nhac/repositories/loja_repository.dart';

/// Serviço TEMPORÁRIO pra descobrir se uma loja está aberta, usando
/// SOMENTE o lojaId, sem depender de nenhum campo novo do backend.
///
/// Mecanismo: GET /lojas/{id} só devolve a loja se ela estiver aberta
/// (isAberto = true no backend) — se estiver fechada ou não existir,
/// devolve 404. Então: sucesso = aberta, erro = fechada.
///
/// Faz cache em memória por lojaId (com deduplicação de chamadas
/// concorrentes) pra não disparar uma requisição por PRODUTO — a Home e a
/// busca mostram vários produtos da MESMA loja, então uma única checagem
/// por loja é reaproveitada por todos eles.
///
/// Isso é uma solução client-side temporária. O jeito definitivo (sem
/// depender de N chamadas extras) é o backend expor esse status direto no
/// ProdutoResumoDTO — quando isso for implantado, este serviço pode ser
/// removido.
class LojaStatusService {
  LojaStatusService._interno();
  static final LojaStatusService _instancia = LojaStatusService._interno();
  factory LojaStatusService() => _instancia;

  final LojaRepository _lojaRepository = LojaRepository();

  final Map<String, bool> _cache = {};
  final Map<String, Future<bool>> _emAndamento = {};

  Future<bool> isLojaAberta(String lojaId) async {
    if (lojaId.isEmpty) return true;

    if (_cache.containsKey(lojaId)) {
      return _cache[lojaId]!;
    }

    // Se já existe uma checagem em andamento pra essa loja (ex: vários
    // ProductCards da mesma loja montando ao mesmo tempo na Home),
    // reaproveita o mesmo Future em vez de disparar chamadas duplicadas.
    if (_emAndamento.containsKey(lojaId)) {
      return _emAndamento[lojaId]!;
    }

    final future = _consultar(lojaId);
    _emAndamento[lojaId] = future;

    try {
      final aberta = await future;
      return aberta;
    } finally {
      _emAndamento.remove(lojaId);
    }
  }

  Future<bool> _consultar(String lojaId) async {
    try {
      final loja = await _lojaRepository.buscarLoja(lojaId);
      final aberta = loja != null;
      _cache[lojaId] = aberta;
      return aberta;
    } catch (_) {
      // 404 (ou qualquer outro erro) = tratamos como fechada, por
      // segurança — melhor bloquear indevidamente do que deixar passar
      // um pedido que vai falhar no checkout.
      _cache[lojaId] = false;
      return false;
    }
  }

  /// Limpa o cache — útil se você quiser forçar uma nova checagem (ex:
  /// pull-to-refresh na Home), já que o status de "aberta" pode mudar ao
  /// longo do dia (horário de funcionamento).
  void limparCache() {
    _cache.clear();
  }
}
