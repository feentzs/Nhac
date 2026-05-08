import 'package:flutter/material.dart';
import 'package:nhac/components/seta_voltar.dart';
import 'package:pay/pay.dart'; // 👈 IMPORT DO PACOTE AQUI

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

  void _onGooglePayResult(dynamic paymentResult) {
    debugPrint('Resultado do Google Pay: $paymentResult');
    // TODO: Enviar o paymentResult para o backend do MercadoPago
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE7E5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SetaVoltar(),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  'Formas de pagamento',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D201C),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Gerencie suas formas de pagamento para suas compras.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 48),

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
                              status: PaymentItemStatus.final_price,
                            )
                          ],
                          type: GooglePayButtonType.pay,
                          margin: const EdgeInsets.only(bottom: 32.0),
                          onPaymentResult: _onGooglePayResult,
                          loadingIndicator: const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFFF6961),
                            ),
                          ),
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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Adicionar forma de pagamento',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6961),
                        ),
                      ),
                      Icon(Icons.add, color: Color(0xFFFF6961)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Divider(color: Colors.grey.shade200, thickness: 1),
                const SizedBox(height: 24),
                Text(
                  '4 formas cadastradas',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 32),
                _buildPaymentItem(
                  icon: Icons.credit_card,
                  title: 'Cartão de crédito',
                  subtitle: 'Mastercard final 1234',
                ),
                _buildPaymentItem(
                  icon: Icons.credit_card_outlined,
                  title: 'Cartão de débito',
                  subtitle: 'Visa final 5678',
                ),
                _buildPaymentItem(
                  icon: Icons.pix,
                  title: 'Pix',
                  subtitle: 'Pagamento instantâneo',
                ),
                _buildPaymentItem(
                  icon: Icons.money,
                  title: 'Dinheiro',
                  subtitle: 'Pagamento na entrega',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 26, color: const Color(0xFF5D201C)),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF5D201C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: Color(0xFF5D201C)),
        ],
      ),
    );
  }
}