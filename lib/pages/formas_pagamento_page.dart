import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nhac/components/seta_voltar.dart';
import 'package:pay/pay.dart';

class FormasPagamentoPage extends StatefulWidget {
  const FormasPagamentoPage({super.key});

  @override
  State<FormasPagamentoPage> createState() => _FormasPagamentoPageState();
}

class _FormasPagamentoPageState extends State<FormasPagamentoPage> {
  late final Future<PaymentConfiguration> _googlePayConfigFuture;

  @override
  void initState() {
    super.initState();
    _googlePayConfigFuture = PaymentConfiguration.fromAsset('gpay_config.json');
  }

  void _onGooglePayResult(dynamic paymentResult) =>
      debugPrint('Resultado do Google Pay: $paymentResult');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE7E5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
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
                FutureBuilder<PaymentConfiguration>(
                  future: _googlePayConfigFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Center(
                        child: GooglePayButton(
                          paymentConfiguration: snapshot.data!,
                          paymentItems: const [
                            PaymentItem(
                                label: 'Total do Pedido',
                                amount: '0.00',
                                status: PaymentItemStatus.final_price)
                          ],
                          type: GooglePayButtonType.pay,
                          margin: EdgeInsets.only(bottom: 32.h),
                          onPaymentResult: _onGooglePayResult,
                          loadingIndicator: Center(
                              child: CircularProgressIndicator(
                                  color: const Color(0xFFFF6961))),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return const Text('Erro ao carregar Google Pay');
                    }
                    return const SizedBox.shrink();
                  },
                ),
                GestureDetector(
                  onTap: () {},
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
                Text('4 formas cadastradas',
                    style: TextStyle(
                        fontSize: 14.sp, color: Colors.grey.shade600)),
                SizedBox(height: 32.h),
                _buildPaymentItem(context,
                    icon: Icons.credit_card,
                    title: 'Cartão de crédito',
                    subtitle: 'Mastercard final 1234'),
                _buildPaymentItem(context,
                    icon: Icons.credit_card_outlined,
                    title: 'Cartão de débito',
                    subtitle: 'Visa final 5678'),
                _buildPaymentItem(context,
                    icon: Icons.pix,
                    title: 'Pix',
                    subtitle: 'Pagamento instantâneo'),
                _buildPaymentItem(context,
                    icon: Icons.money,
                    title: 'Dinheiro',
                    subtitle: 'Pagamento na entrega'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentItem(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 32.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.r),
        onTap: () => Navigator.pop(context, title),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 26.sp, color: const Color(0xFF5D201C)),
            SizedBox(width: 20.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF5D201C))),
                  SizedBox(height: 4.h),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 14.sp, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Icon(Icons.more_vert, color: const Color(0xFF5D201C)),
          ],
        ),
      ),
    );
  }
}
