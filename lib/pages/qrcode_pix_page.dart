import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';

import 'package:nhac/components/botoes/botao_largo_nhac.dart';

class QrCodePixPage extends StatefulWidget {
  final String pixQrCode;
  final String? pixCopiaECola;
  final String paymentId;
  final double valor;

  const QrCodePixPage({
    super.key,
    required this.pixQrCode,
    this.pixCopiaECola,
    required this.paymentId,
    required this.valor,
  });

  @override
  State<QrCodePixPage> createState() => _QrCodePixPageState();
}

class _QrCodePixPageState extends State<QrCodePixPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagamento PIX'),
        backgroundColor: const Color(0xFFFF6961),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              SizedBox(height: 32.h),
              // Título
              Text(
                'Escaneie o QR Code',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF5D201C),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Use seu app de banco para escanear e pagar',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 48.h),
              // QR Code
              Semantics(
                label:
                    'QR Code PIX. Valor de R\$ ${widget.valor.toStringAsFixed(2)}',
                image: true,
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: widget.pixQrCode,
                    version: QrVersions.auto,
                    size: 250.w,
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              // Valor
              MergeSemantics(
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE7E5),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Valor a pagar:',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        'R\$ ${widget.valor.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF5D201C),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 48.h),
              // Botão de confirmação
              BotaoLargoNhac(
                texto: 'Ir para Acompanhamento de Pedido',
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
              SizedBox(height: 16.h),
              OutlinedButton(
                onPressed: () {
                  final textToCopy = widget.pixCopiaECola ?? widget.pixQrCode;
                  Clipboard.setData(ClipboardData(text: textToCopy));

                  SemanticsService.announce(
                      'Código PIX copiado com sucesso!', TextDirection.ltr);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Código PIX copiado!')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50.h),
                ),
                child: Text(
                  'Copiar código PIX',
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
