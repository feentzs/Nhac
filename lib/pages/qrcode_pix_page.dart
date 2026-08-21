import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:nhac/controllers/payment_provider.dart';
import 'package:flutter/services.dart';

// Assuming BotaoLargoNhac exists in components/botoes. Otherwise using standard ElevatedButton
import 'package:nhac/components/botoes/botao_largo_nhac.dart';

class QrCodePixPage extends StatefulWidget {
  final String pixQrCode;
  final String paymentId;
  final double valor;

  const QrCodePixPage({
    super.key,
    required this.pixQrCode,
    required this.paymentId,
    required this.valor,
  });

  @override
  State<QrCodePixPage> createState() => _QrCodePixPageState();
}

class _QrCodePixPageState extends State<QrCodePixPage> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Verificar status do pagamento a cada 5 segundos
    _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      // Chamar seu backend para verificar se foi pago
      // Se sim, mostrar confirmação e fechar
    });
  }

  @override
  void dispose() {
    _timer.cancel();
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
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: widget.pixQrCode,
                  version: QrVersions.auto,
                  size: 250.w,
                  // If the image asset doesn't exist, remove embeddedImage to avoid errors
                  // embeddedImage: const AssetImage('assets/nhac-logo.png'),
                  // embeddedImageStyle: QrEmbeddedImageStyle(
                  //   size: Size(50.w, 50.w),
                  // ),
                ),
              ),
              SizedBox(height: 32.h),
              // Valor
              Container(
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
              SizedBox(height: 48.h),
              // Botão de confirmação
              BotaoLargoNhac(
                titulo: 'Já realizei o pagamento',
                onPressed: () => Navigator.pop(context),
              ),
              SizedBox(height: 16.h),
              // Botão secundário
              OutlinedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.pixQrCode));
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
