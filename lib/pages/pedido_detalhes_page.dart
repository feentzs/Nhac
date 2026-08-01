import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:nhac/components/seta_voltar.dart';
import 'package:nhac/globals/status_pedido_info.dart';
import 'package:nhac/models/pedido_model.dart';
import 'package:nhac/repositories/pedido_repository.dart';
import 'package:nhac/pages/avaliar_pedido_page.dart';

class PedidoDetalhesPage extends StatefulWidget {
  final String pedidoId;
  const PedidoDetalhesPage({super.key, required this.pedidoId});

  @override
  State<PedidoDetalhesPage> createState() => _PedidoDetalhesPageState();
}

class _PedidoDetalhesPageState extends State<PedidoDetalhesPage> {
  final _pedidoRepository = PedidoRepository();
  late Future<PedidoModel> _pedidoFuture;
  final _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void initState() {
    super.initState();
    _pedidoFuture = _pedidoRepository.buscarPedidoPorId(widget.pedidoId);
  }

  String _formatarData(String? iso) {
    if (iso == null) return '';
    final data = DateTime.tryParse(iso);
    if (data == null) return '';
    return DateFormat('dd/MM/yyyy \'às\' HH:mm').format(data.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F6),
      body: SafeArea(
        child: FutureBuilder<PedidoModel>(
          future: _pedidoFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return _buildErro('${snapshot.error}');
            }

            final pedido = snapshot.data!;
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(pedido)),
                SliverToBoxAdapter(child: _buildLinhaDoTempo(pedido)),
                SliverToBoxAdapter(child: _buildItens(pedido)),
                SliverToBoxAdapter(child: _buildEndereco(pedido)),
                SliverToBoxAdapter(child: _buildPagamento(pedido)),
                if (pedido.status == 'ENTREGUE') SliverToBoxAdapter(child: _buildBotaoAvaliar(pedido)),
                SliverToBoxAdapter(child: SizedBox(height: 32.h)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildErro(String erro) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SetaVoltar(),
            SizedBox(height: 16.h),
            Icon(Icons.error_outline, size: 48.r, color: Colors.red.shade300),
            SizedBox(height: 12.h),
            Text('Não foi possível carregar este pedido.', textAlign: TextAlign.center),
            SizedBox(height: 4.h),
            Text(erro, textAlign: TextAlign.center, style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(PedidoModel pedido) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          const SetaVoltar(),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pedido.lojaNome ?? 'Pedido',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: const Color(0xFF5D201C))),
                Text('Pedido #${(pedido.id ?? '').substring(0, (pedido.id?.length ?? 0).clamp(0, 8))}',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String titulo, required Widget child}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(color: const Color(0xFF5D201C).withValues(alpha: 0.05), blurRadius: 10.r, offset: Offset(0, 4.h)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: const Color(0xFF5D201C))),
            SizedBox(height: 12.h),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildLinhaDoTempo(PedidoModel pedido) {
    final historico = pedido.historicoStatus;
    final statusAtual = pedido.status ?? 'PENDENTE';

    if (pedido.status == 'CANCELADO') {
      return _buildCard(
        titulo: 'Status',
        child: Row(
          children: [
            Icon(StatusPedidoInfo.daString('CANCELADO').icon, color: Colors.red, size: 20.r),
            SizedBox(width: 8.w),
            const Text('Pedido cancelado', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    final indiceAtual = StatusPedidoInfo.ordemFluxoNormal.indexOf(statusAtual);

    return _buildCard(
      titulo: 'Acompanhar pedido',
      child: Column(
        children: List.generate(StatusPedidoInfo.ordemFluxoNormal.length, (index) {
          final statusEtapa = StatusPedidoInfo.ordemFluxoNormal[index];
          final info = StatusPedidoInfo.daString(statusEtapa);
          final concluido = indiceAtual >= 0 && index <= indiceAtual;
          final ultimo = index == StatusPedidoInfo.ordemFluxoNormal.length - 1;

          final entradaHistorico = historico?.where((h) => h.statusNovo == statusEtapa).firstOrNull;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Icon(
                    concluido ? Icons.check_circle : Icons.circle_outlined,
                    color: concluido ? info.cor : Colors.grey.shade300,
                    size: 20.r,
                  ),
                  if (!ultimo)
                    Container(
                      width: 2,
                      height: 32.h,
                      color: concluido ? info.cor : Colors.grey.shade300,
                    ),
                ],
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info.label,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: concluido ? FontWeight.w600 : FontWeight.normal,
                          color: concluido ? const Color(0xFF5D201C) : Colors.grey.shade400,
                        ),
                      ),
                      if (entradaHistorico != null)
                        Text(_formatarData(entradaHistorico.alteradoEm),
                            style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildItens(PedidoModel pedido) {
    return _buildCard(
      titulo: 'Itens do pedido',
      child: Column(
        children: [
          ...pedido.itens.map((item) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  children: [
                    Text('${item.quantidade}x', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
                    SizedBox(width: 8.w),
                    Expanded(child: Text(item.nome, style: TextStyle(fontSize: 13.sp))),
                    Text(_currencyFormat.format(item.preco * item.quantidade), style: TextStyle(fontSize: 13.sp)),
                  ],
                ),
              )),
          Divider(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Taxa de entrega', style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600)),
              Text(_currencyFormat.format(pedido.taxaFrete), style: TextStyle(fontSize: 13.sp)),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp)),
              Text(_currencyFormat.format(pedido.valorTotal),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp, color: const Color(0xFF5D201C))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEndereco(PedidoModel pedido) {
    final e = pedido.enderecoEntrega;
    return _buildCard(
      titulo: 'Endereço de entrega',
      child: Text(
        '${e.rua}, ${e.numero}${(e.complemento ?? '').isNotEmpty ? ' - ${e.complemento}' : ''}\n${e.bairro}, ${e.cidade} - ${e.estado}\nCEP: ${e.cep}',
        style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700),
      ),
    );
  }

  Widget _buildPagamento(PedidoModel pedido) {
    return _buildCard(
      titulo: 'Forma de pagamento',
      child: Text(
        pedido.trocoPara != null
            ? '${pedido.formaPagamento} (troco para ${_currencyFormat.format(pedido.trocoPara)})'
            : pedido.formaPagamento,
        style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700),
      ),
    );
  }

  Widget _buildBotaoAvaliar(PedidoModel pedido) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AvaliarPedidoPage(
                  pedidoId: pedido.id!,
                  lojaId: pedido.lojaId,
                  lojaNome: pedido.lojaNome ?? 'Loja',
                ),
              ),
            );
          },
          icon: const Icon(Icons.star_outline),
          label: const Text('Avaliar pedido'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6961),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.r)),
          ),
        ),
      ),
    );
  }
}
