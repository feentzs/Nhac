import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nhac/components/seta_voltar.dart';
import 'package:nhac/globals/ui_utils.dart';
import 'package:nhac/models/usuario/metodos_pagamento_model.dart';
import 'package:nhac/repositories/pagamento_repository.dart';
import 'package:nhac/services/auth_service.dart';
import 'package:provider/provider.dart';

class FormasPagamentoPage extends StatefulWidget {
  const FormasPagamentoPage({super.key});

  @override
  State<FormasPagamentoPage> createState() => _FormasPagamentoPageState();
}

class _FormasPagamentoPageState extends State<FormasPagamentoPage> {
  final PagamentoRepository _repository = PagamentoRepository();
  List<MetodosPagamentoModel> _metodos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarPagamentos();
  }

  Future<void> _carregarPagamentos() async {
    final auth = context.read<AuthService>();
    if (auth.usuarioId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final metodos = await _repository.buscarPagamentos(auth.usuarioId!);
      if (mounted) {
        setState(() {
          _metodos = metodos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        context.showError(e.toString());
      }
    }
  }

  Future<void> _removerPagamento(String pagamentoId) async {
    final auth = context.read<AuthService>();
    if (auth.usuarioId == null) return;

    try {
      await _repository.removerPagamento(auth.usuarioId!, pagamentoId);
      if (mounted) {
        setState(() {
          _metodos.removeWhere((m) => m.id == pagamentoId);
        });
        context.showSuccess('Forma de pagamento removida.');
      }
    } catch (e) {
      if (mounted) {
        context.showError(e.toString());
        await _carregarPagamentos(); // Recarrega se der erro
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE7E5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [SetaVoltar()]),
                  SizedBox(height: 32.h),
                  Text('Formas de pagamento',
                      style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF5D201C))),
                  SizedBox(height: 8.h),
                  Text('Gerencie suas formas de pagamento para suas compras.',
                      style: TextStyle(
                          fontSize: 16.sp, color: Colors.grey.shade600)),
                  SizedBox(height: 48.h),
                  GestureDetector(
                    onTap: () {
                      context.showSuccess('Adicionar cartão em breve');
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Adicionar forma de pagamento',
                            style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFF6961))),
                        Icon(Icons.add, color: const Color(0xFFFF6961)),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Divider(color: Colors.grey.shade200, thickness: 1),
                  SizedBox(height: 24.h),
                  if (!_isLoading)
                    Text('${_metodos.length} forma(s) cadastrada(s)',
                        style: TextStyle(
                            fontSize: 14.sp, color: Colors.grey.shade600)),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF6961)))
                  : _metodos.isEmpty
                      ? Center(child: Text('Nenhuma forma de pagamento salva.', style: TextStyle(color: Colors.grey.shade600)))
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          itemCount: _metodos.length,
                          itemBuilder: (context, index) {
                            final metodo = _metodos[index];
                            return _buildPaymentItem(context, metodo);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentItem(BuildContext context, MetodosPagamentoModel metodo) {
    IconData icon;
    if (metodo.tipo.toLowerCase().contains('credito')) {
      icon = Icons.credit_card;
    } else if (metodo.tipo.toLowerCase().contains('debito')) {
      icon = Icons.credit_card_outlined;
    } else if (metodo.tipo.toLowerCase().contains('pix')) {
      icon = Icons.pix;
    } else {
      icon = Icons.money;
    }

    return Dismissible(
      key: Key(metodo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        _removerPagamento(metodo.id);
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: 32.h),
        child: InkWell(
          borderRadius: BorderRadius.circular(8.r),
          onTap: () => context.pop(metodo.nomeCartao),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 26.sp, color: const Color(0xFF5D201C)),
              SizedBox(width: 20.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(metodo.nomeCartao,
                            style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF5D201C))),
                        if (metodo.isPadrao) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6961).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text('Padrão', style: TextStyle(color: const Color(0xFFFF6961), fontSize: 10.sp, fontWeight: FontWeight.bold)),
                          )
                        ]
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text('${metodo.bandeira} final ${metodo.ultimosDigitos}',
                        style: TextStyle(
                            fontSize: 14.sp, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Icon(Icons.more_vert, color: const Color(0xFF5D201C)),
            ],
          ),
        ),
      ),
    );
  }
}
