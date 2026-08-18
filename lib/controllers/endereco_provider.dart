import 'package:flutter/material.dart';
import 'package:nhac/globals/router.dart';
import 'package:nhac/models/usuario/endereco_model.dart';
import 'package:nhac/repositories/endereco_repository.dart';
import 'package:nhac/services/auth_service.dart';

class EnderecoProvider with ChangeNotifier {
  final EnderecoRepository _enderecoRepository;
  final AuthService _authService;

  EnderecoProvider({AuthService? authService, EnderecoRepository? repository})
      : _authService = authService ?? authServiceRoteador,
        _enderecoRepository = repository ?? EnderecoRepository();

  List<EnderecoModel> _enderecos = [];
  bool _isLoading = false;

  List<EnderecoModel> get enderecos => _enderecos;
  bool get isLoading => _isLoading;

  Future<void> buscarEnderecos() async {
    final usuarioId = _authService.usuarioId;
    if (usuarioId == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      _enderecos = await _enderecoRepository.buscarEnderecos(usuarioId);
    } catch (e) {
      debugPrint("Erro ao buscar endereços: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> adicionarEndereco(EnderecoModel endereco) async {
    final usuarioId = _authService.usuarioId;
    if (usuarioId == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      await _enderecoRepository.adicionarEndereco(usuarioId, endereco);
      await buscarEnderecos();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint("Erro ao adicionar endereço: $e");
      rethrow;
    }
  }

  Future<void> removerEndereco(String enderecoId) async {
    final usuarioId = _authService.usuarioId;
    if (usuarioId == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      await _enderecoRepository.removerEndereco(usuarioId, enderecoId);
      await buscarEnderecos();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint("Erro ao remover endereço: $e");
      rethrow;
    }
  }

  Future<void> atualizarEndereco(String enderecoId, EnderecoModel endereco) async {
    final usuarioId = _authService.usuarioId;
    if (usuarioId == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      await _enderecoRepository.atualizarEndereco(usuarioId, enderecoId, endereco);
      await buscarEnderecos();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint("Erro ao atualizar endereço: $e");
      rethrow;
    }
  }

  Future<void> definirComoPadrao(String enderecoId) async {
    final usuarioId = _authService.usuarioId;
    if (usuarioId == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final enderecoSelecionado = _enderecos.firstWhere((e) => e.id == enderecoId);
      final enderecoPadraoAtual = _enderecos.cast<EnderecoModel?>().firstWhere((e) => e?.isPadrao == true && e?.id != enderecoId, orElse: () => null);

      if (enderecoPadraoAtual != null) {
        await _enderecoRepository.atualizarEndereco(
          usuarioId,
          enderecoPadraoAtual.id,
          enderecoPadraoAtual.copyWith(isPadrao: false),
        );
      }

      await _enderecoRepository.atualizarEndereco(
        usuarioId,
        enderecoId,
        enderecoSelecionado.copyWith(isPadrao: true),
      );

      await buscarEnderecos();
    } catch (e) {
      debugPrint("Erro ao definir como padrão: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
