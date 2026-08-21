import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:nhac/services/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';

class PaymentService {
  final String _asaasApiKey = dotenv.env['ASAAS_API_KEY'] ?? '';
  final String _asaasBaseUrl = 'https://api.asaas.com/v3';

  /// Criar cobrança PIX no Asaas
  Future<Map<String, dynamic>> criarCobrancaPix({
    required double valor,
    required String descricao,
    required String email,
  }) async {
    try {
      final response = await ApiClient().dio.post(
        '$_asaasBaseUrl/payments',
        data: {
          'customer': email,
          'billingType': 'PIX', // PIX, CREDIT_CARD, BOLETO, etc
          'value': valor,
          'description': descricao,
          'dueDate': DateTime.now().toIso8601String(),
        },
        options: Options(headers: {'access_token': _asaasApiKey}),
      );
      return response.data;
    } catch (e) {
      throw Exception('Erro ao criar cobrança PIX: $e');
    }
  }

  /// Obter QR Code PIX
  Future<String> obterQrCodePix(String paymentId) async {
    try {
      final response = await ApiClient().dio.get(
        '$_asaasBaseUrl/payments/$paymentId/pixQrCode',
        options: Options(headers: {'access_token': _asaasApiKey}),
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
      final response = await ApiClient().dio.post(
        '/create-payment-intent',
        data: {'amount': (valor * 100).toInt()}, // Stripe usa centavos
      );
      return response.data;
    } catch (e) {
      throw Exception('Erro ao criar intent: $e');
    }
  }
}
