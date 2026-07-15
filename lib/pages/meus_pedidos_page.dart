import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:nhac/components/seta_voltar.dart';
import 'package:nhac/globals/status_pedido_info.dart';
import 'package:nhac/models/pedido_model.dart';
import 'package:nhac/repositories/pedido_repository.dart';
import 'package:nhac/pages/pedido_detalhes_page.dart';

class MeusPedidosPage extends StatefulWidget {
  const MeusPedidosPage({super.key});

  @override
  State<MeusPedidosPage> createState() => _MeusPedidosPageState();
}

class _MeusPedidosPageState extends State<MeusPedidosPage> {
  final _pedidoRepository = PedidoRepository();
  late Future<List<PedidoModel>> _pedidosFuture;
  final _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  void initState() {
    super.initState();
    _pedidosFuture = _pedidoRepository.buscarMeusPedidos();
  }

  Future<void> _recarregar() async {
    setState(() {
      _pedidosFuture = _pedidoRepository.buscarMeusPedidos();
    });
    await _pedidosFuture;
  }

  String _formatarData(String? criadoEm) {
    if (criadoEm == null) return '';
    final data = DateTime.tryParse(criadoEm);
    if (data == null) return '';
    return DateFormat('dd/MM/yyyy \'às\' HH:mm').format(data.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F6),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  const SetaVoltar(),
                  SizedBox(width: 16.w),
                  Text(
                    'Meus Pedidos',
                    style: TextStyle(
                        fontSize: 20.sp, fontWeight: FontWeight.bold, color: const Color(0xFF5D201C)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _recarregar,
                child: FutureBuilder<List<PedidoModel>>(
                  future: _pedidosFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return _buildErro(snapshot.error.toString());
                    }
                    final pedidos = snapshot.data ?? [];
                    if (pedidos.isEmpty) {
                      return _buildVazio();
                    }
                    return ListView.separated(
                      padding: EdgeInsets.all(16.w),
                      itemCount: pedidos.length,
                      separatorBuilder: (context, index) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) => _buildPedidoCard(pedidos[index]),
                    );
                  },
                ),
              ),
            ),
          ],
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
            Icon(Icons.error_outline, size: 48.r, color: Colors.red.shade300),
            SizedBox(height: 12.h),
            Text('Não foi possível carregar seus pedidos.',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 14.sp)),
            SizedBox(height: 4.h),
            Text(erro,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  Widget _buildVazio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64.r, color: Colors.grey.shade300),
          SizedBox(height: 16.h),
          Text('Você ainda não fez nenhum pedido',
              style: TextStyle(fontSize: 15.sp, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildPedidoCard(PedidoModel pedido) {
    final statusInfo = StatusPedidoInfo.daString(pedido.status);
    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PedidoDetalhesPage(pedidoId: pedido.id!)),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5D201C).withValues(alpha: 0.05),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    pedido.lojaNome ?? 'Loja',
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: const Color(0xFF5D201C)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _currencyFormat.format(pedido.valorTotal),
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: const Color(0xFF5D201C)),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              _formatarData(pedido.criadoEm),
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(statusInfo.icon, size: 16.r, color: statusInfo.cor),
                SizedBox(width: 6.w),
                Text(
                  statusInfo.label,
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: statusInfo.cor),
                ),
                const Spacer(),
                Text(
                  '${pedido.itens.length} ${pedido.itens.length == 1 ? "item" : "itens"}',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
                ),
                SizedBox(width: 4.w),
                Icon(Icons.arrow_forward_ios_rounded, size: 12.r, color: Colors.grey.shade400),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
