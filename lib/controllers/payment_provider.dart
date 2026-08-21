import 'package:flutter/foundation.dart';
import 'package:nhac/services/payment_service.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentService _paymentService = PaymentService();

  String? _qrCodeBase64;
  String? _paymentId;
  bool _isLoading = false;
  String? _error;

  String? get qrCodeBase64 => _qrCodeBase64;
  String? get paymentId => _paymentId;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Processar pagamento PIX
  Future<void> processarPagamentoPix({
    required double valor,
    required String descricao,
    required String email,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Criar cobrança no Asaas
      final cobranca = await _paymentService.criarCobrancaPix(
        valor: valor,
        descricao: descricao,
        email: email,
      );
      _paymentId = cobranca['id'];

      // 2. Obter QR Code
      _qrCodeBase64 = await _paymentService.obterQrCodePix(_paymentId!);

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void limpar() {
    _qrCodeBase64 = null;
    _paymentId = null;
    _error = null;
    notifyListeners();
  }
}
