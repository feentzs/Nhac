import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nhac/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:nhac/components/botoes/botao_largo_nhac.dart'; 
import 'package:nhac/globals/ui_utils.dart';
import 'package:nhac/components/nhac_input_field.dart';
import 'package:nhac/utils/validators.dart';

class EditarSenhaPage extends StatefulWidget {
  const EditarSenhaPage({super.key});

  @override
  State<EditarSenhaPage> createState() => _EditarSenhaPageState();
}

class _EditarSenhaPageState extends State<EditarSenhaPage> {
  final TextEditingController _senhaAtualController = TextEditingController();
  final TextEditingController _novaSenhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController = TextEditingController();
  
  bool _formValido = false;
  String? _erroSenhaAtual;
  String? _erroNovaSenha;
  String? _erroConfirmarSenha;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _senhaAtualController.addListener(_validarForm);
    _novaSenhaController.addListener(_validarForm);
    _confirmarSenhaController.addListener(_validarForm);
  }

  @override
  void dispose() {
    _senhaAtualController.dispose();
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  void _validarForm() {
    if (!mounted) return;
    
    final senhaAtual = _senhaAtualController.text;
    final novaSenha = _novaSenhaController.text;
    final confirmarSenha = _confirmarSenhaController.text;

    setState(() {
      _erroSenhaAtual = senhaAtual.isEmpty ? 'Senha atual é obrigatória' : null;
      _erroNovaSenha = Validators.validarSenha(novaSenha);
      
      if (confirmarSenha.isNotEmpty && confirmarSenha != novaSenha) {
        _erroConfirmarSenha = 'As senhas não coincidem';
      } else {
        _erroConfirmarSenha = null;
      }

      _formValido = _erroSenhaAtual == null &&
          _erroNovaSenha == null &&
          _erroConfirmarSenha == null &&
          confirmarSenha.isNotEmpty &&
          novaSenha.isNotEmpty &&
          senhaAtual.isNotEmpty;
    });
  }

  Future<void> _processarAtualizacaoSenha() async {
    try {
      setState(() => _isLoading = true);
      
      final authService = context.read<AuthService>();
      
      await authService.alterarSenha(_senhaAtualController.text, _novaSenhaController.text);
      
      if (!mounted) return;
      
      context.showSuccess('Senha alterada com sucesso!');
      context.pop(); 
      
    } catch (e) {
      if (mounted) {
        final mensagemErro = e.toString();
        context.showError(mensagemErro);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE7E5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFE7E5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF5D201C), size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16.0),
                      const Text(
                        'Alterar Senha',
                        style: TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D201C),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        'Digite sua senha atual e a nova senha.',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28.0),
                      NhacInputField(
                        controller: _senhaAtualController,
                        obscureText: true,
                        errorText: _erroSenhaAtual,
                        hintText: 'Senha Atual',
                        style: const TextStyle(
                          fontSize: 18.0,
                          color: Color(0xFF5D201C),
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      NhacInputField(
                        controller: _novaSenhaController,
                        obscureText: true,
                        errorText: _erroNovaSenha,
                        hintText: 'Nova Senha',
                        style: const TextStyle(
                          fontSize: 18.0,
                          color: Color(0xFF5D201C),
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      NhacInputField(
                        controller: _confirmarSenhaController,
                        obscureText: true,
                        errorText: _erroConfirmarSenha,
                        hintText: 'Confirmar Nova Senha',
                        style: const TextStyle(
                          fontSize: 18.0,
                          color: Color(0xFF5D201C),
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 32.0, top: 16.0),
              child: BotaoLargoNhac(
                texto: 'Salvar Alteração',
                carregando: _isLoading,
                onPressed: _formValido ? () => _processarAtualizacaoSenha() : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
