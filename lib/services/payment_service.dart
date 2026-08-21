import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class PaymentService {
  final Dio _dio = Dio();
  final String _asaasApiKey = 'YOUR_ASAAS_API_KEY'; // Replace with your actual key
  final String _asaasBaseUrl = 'https://api.asaas.com/v3';

  PaymentService() {
    _dio.options.headers['Authorization'] = 'Bearer $_asaasApiKey';
  }

  /// Criar cobrança PIX no Asaas
  Future<Map<String, dynamic>> criarCobrancaPix({
    required double valor,
    required String descricao,
    required String email,
  }) async {
    try {
      final response = await _dio.post(
        '$_asaasBaseUrl/payments',
        data: {
          'customer': email,
          'billingType': 'PIX', // PIX, CREDIT_CARD, BOLETO, etc
          'value': valor,
          'description': descricao,
          'dueDate': DateTime.now().toIso8601String(),
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('Erro ao criar cobrança PIX: $e');
    }
  }

  /// Obter QR Code PIX
  Future<String> obterQrCodePix(String paymentId) async {
    try {
      final response = await _dio.get(
        '$_asaasBaseUrl/payments/$paymentId/pixQrCode',
      );
      // O response contém 'encodedImage' (base64) no v3 geralmente
      return response.data['encodedImage'] ?? '';
    } catch (e) {
      throw Exception('Erro ao obter QR Code: $e');
    }
  }

  /// Criar pagamento com Stripe (Card)
  Future<String> criarPagamentoStripe({
    required double valor,
    required String token, // Token do cartão
    required String email,
  }) async {
    try {
      final paymentIntent = await _criarPaymentIntent(valor);
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'Nhac',
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      return paymentIntent['id'];
    } catch (e) {
      throw Exception('Erro ao processar pagamento Stripe: $e');
    }
  }

  /// Helper: Criar Payment Intent no seu backend
  Future<Map<String, dynamic>> _criarPaymentIntent(double valor) async {
    try {
      // Chamar seu backend que chamará Stripe
      final response = await _dio.post(
        'YOUR_BACKEND_URL/create-payment-intent',
        data: {'amount': (valor * 100).toInt()}, // Stripe usa centavos
      );
      return response.data;
    } catch (e) {
      throw Exception('Erro ao criar intent: $e');
    }
  }
}
