import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nhac/controllers/user_provider.dart';
import 'package:nhac/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:nhac/components/botoes/botao_largo_nhac.dart'; 
import 'package:nhac/globals/ui_utils.dart';
import 'package:nhac/components/nhac_input_field.dart';
import 'package:nhac/utils/validators.dart';

class EditarEmailPage extends StatefulWidget {
  const EditarEmailPage({super.key});

  @override
  State<EditarEmailPage> createState() => _EditarEmailPageState();
}

class _EditarEmailPageState extends State<EditarEmailPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _emailValido = false;
  String? _erroEmail;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validarNovoEmail);
  }

  @override
  void dispose() {
    _emailController.removeListener(_validarNovoEmail);
    _emailController.dispose();
    super.dispose();
  }

  void _validarNovoEmail() {
    if (!mounted) return;
    
    final texto = _emailController.text.trim();
    final emailAtual = context.read<UserProvider>().usuario?.email.trim() ?? '';

    if (texto.isEmpty) {
      setState(() {
        _erroEmail = null;
        _emailValido = false;
      });
      return;
    }

    String? erroTemp = Validators.validarEmail(texto);

    if (erroTemp == null && emailAtual.isNotEmpty && texto.toLowerCase() == emailAtual.toLowerCase()) {
      erroTemp = 'Este e-mail já está sendo utilizado pela sua conta';
    }

    setState(() {
      _erroEmail = erroTemp;
      _emailValido = erroTemp == null && texto.isNotEmpty;
    });
  }

  Future<void> _processarAtualizacaoEmail() async {
    try {
      setState(() => _isLoading = true);
      
      final authService = context.read<AuthService>();
      final userProvider = context.read<UserProvider>();
      
      // 1. Chama a atualização na API
      await authService.updateEmail(novoEmail: _emailController.text.trim());
      
      // 2. Avisa o Provider para recarregar os dados para a tela de Perfil atualizar
      await userProvider.carregarDadosUsuario();
      
      if (!mounted) return;
      
      // 3. Volta para a tela anterior com sucesso
      context.showSuccess('E-mail alterado com sucesso!');
      context.pop(); 
      
    } catch (e) {
      if (mounted) {
        final mensagemErro = e.toString();
        final lower = mensagemErro.toLowerCase();
        if (lower.contains('já') ||
            lower.contains('ja') ||
            lower.contains('uso') ||
            lower.contains('existe') ||
            lower.contains('cadastrado') ||
            lower.contains('duplicate') ||
            lower.contains('already')) {
          setState(() {
            _erroEmail = 'Este e-mail já está em uso';
            _emailValido = false;
          });
        }
        context.showError(mensagemErro);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos o seu próprio Provider para saber se é usuário do Google
    final isGoogleUser = context.watch<UserProvider>().isGoogleUser;

    if (isGoogleUser) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuários do Google não podem alterar o e-mail por aqui.')),
          );
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
                        'Digite seu novo endereço de email',
                        style: TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D201C),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        'Seu e-mail será atualizado imediatamente na sua conta.',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28.0),
                      NhacInputField(
                        controller: _emailController,
                        autofocus: true,
                        onChanged: (value) => _validarNovoEmail(),
                        keyboardType: TextInputType.emailAddress,
                        errorText: _erroEmail,
                        hintText: 'Novo e-mail',
                        validator: Validators.validarEmail,
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
                onPressed: _emailValido ? () => _processarAtualizacaoEmail() : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}