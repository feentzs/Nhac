import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nhac/components/botoes/botao_largo_nhac.dart';
import 'package:nhac/components/seta_voltar.dart';
import 'package:nhac/globals/ui_utils.dart';
import 'package:nhac/models/avaliacao_model.dart';
import 'package:nhac/repositories/avaliacao_repository.dart';

class AvaliarPedidoPage extends StatefulWidget {
  final String pedidoId;
  final String lojaId;
  final String lojaNome;

  const AvaliarPedidoPage({
    super.key,
    required this.pedidoId,
    required this.lojaId,
    required this.lojaNome,
  });

  @override
  State<AvaliarPedidoPage> createState() => _AvaliarPedidoPageState();
}

class _AvaliarPedidoPageState extends State<AvaliarPedidoPage> {
  final _avaliacaoRepository = AvaliacaoRepository();
  final _comentarioController = TextEditingController();
  int _notaSelecionada = 0;
  bool _enviando = false;

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  Future<void> _enviarAvaliacao() async {
    if (_notaSelecionada == 0) {
      context.showError('Selecione de 1 a 5 estrelas antes de enviar.');
      return;
    }

    setState(() => _enviando = true);
    try {
      await _avaliacaoRepository.avaliarPedido(AvaliacaoModel(
        pedidoId: widget.pedidoId,
        lojaId: widget.lojaId,
        nota: _notaSelecionada,
        comentario: _comentarioController.text.trim().isEmpty ? null : _comentarioController.text.trim(),
      ));
      if (mounted) {
        context.showSuccess('Avaliação enviada, obrigado!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) context.showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F6),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SetaVoltar(),
                  SizedBox(width: 16.w),
                  Text('Avaliar pedido',
                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: const Color(0xFF5D201C))),
                ],
              ),
              SizedBox(height: 24.h),
              Center(
                child: Column(
                  children: [
                    Text('Como foi seu pedido em', style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600)),
                    Text(widget.lojaNome,
                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: const Color(0xFF5D201C))),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final estrela = index + 1;
                        return IconButton(
                          iconSize: 40.r,
                          onPressed: () => setState(() => _notaSelecionada = estrela),
                          icon: Icon(
                            estrela <= _notaSelecionada ? Icons.star : Icons.star_border,
                            color: const Color(0xFFFF6961),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Text('Comentário (opcional)', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 8.h),
              TextField(
                controller: _comentarioController,
                maxLines: 4,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'Conte como foi sua experiência...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const Spacer(),
              BotaoLargoNhac(
                texto: 'Enviar avaliação',
                carregando: _enviando,
                onPressed: _enviando ? null : _enviarAvaliacao,
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}
