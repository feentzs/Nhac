import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';
import 'package:nhac/controllers/user_provider.dart';
import 'package:nhac/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:nhac/components/botao_largo_nhac.dart'; 
import 'dart:async';
import 'package:pin_code_fields/pin_code_fields.dart';

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
    _emailController.dispose();
    super.dispose();
  }

  void _validarNovoEmail() {
    if (!mounted) return;
    final texto = _emailController.text;
    final usuarioLogado = FirebaseAuth.instance.currentUser;
    final emailAtual = usuarioLogado?.email ?? '';

    String? erroTemp = Validators.validarEmail(texto);

    if (erroTemp == null && texto.toLowerCase() == emailAtual.toLowerCase()) {
      erroTemp = 'Este já é o seu e-mail atual';
    }

    setState(() {
      _erroEmail = erroTemp;
      _emailValido = erroTemp == null && texto.isNotEmpty;
    });
  }

  Future<void> _processarAtualizacaoEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final hasPassword = user.providerData.any((info) => info.providerId == 'password');
    final hasPhone = user.providerData.any((info) => info.providerId == 'phone');

    if (hasPassword) {
      _mostrarDialogoConfirmacaoSenha();
    } else if (hasPhone) {
      _mostrarDialogoConfirmacaoTelefone();
    } else {
      await _atualizarEmailSemSenha();
    }
  }

  Future<void> _mostrarDialogoConfirmacaoTelefone() async {
    final parentContext = context;
    final user = FirebaseAuth.instance.currentUser;
    final telefoneCompleto = user?.phoneNumber ?? '';
    final telefoneLimpo = telefoneCompleto.replaceAll('+55', '');
    final authService = parentContext.read<AuthService>();

    String? vId;
    bool enviandoSms = true;
    bool verificandoCodigo = false;
    String? erroSms;
    int tempoRestante = 60;
    Timer? timer;

    void iniciarTimer(StateSetter setStateDialog) {
      tempoRestante = 60;
      timer?.cancel();
      timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (tempoRestante > 0) {
          setStateDialog(() => tempoRestante--);
        } else {
          t.cancel();
        }
      });
    }

    void enviarSms(StateSetter setStateDialog) async {
      setStateDialog(() {
        enviandoSms = true;
        erroSms = null;
      });

      try {
        await authService.enviarSmsDeVerificacao(
          telefone: telefoneLimpo,
          onCodeSent: (id) {
            setStateDialog(() {
              vId = id;
              enviandoSms = false;
            });
            iniciarTimer(setStateDialog);
          },
          onFailed: (erro) {
            setStateDialog(() {
              erroSms = erro;
              enviandoSms = false;
            });
          },
        );
      } catch (e) {
        setStateDialog(() {
          erroSms = e.toString();
          enviandoSms = false;
        });
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            if (enviandoSms && vId == null) {
              enviarSms(setStateDialog);
            }

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'Verifique seu número',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF5D201C)),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (enviandoSms && vId == null)
                    const Center(child: CircularProgressIndicator(color: Color(0xFFFE645C)))
                  else if (erroSms != null)
                    Text(erroSms!, style: const TextStyle(color: Colors.red))
                  else ...[
                    Text(
                      'Enviamos um código para $telefoneCompleto para confirmar sua identidade.',
                      style: const TextStyle(color: Color(0xFF5D201C)),
                    ),
                    const SizedBox(height: 20),
                    PinCodeTextField(
                      appContext: context,
                      length: 6,
                      onChanged: (_) {},
                      onCompleted: (code) async {
                        setStateDialog(() => verificandoCodigo = true);
                        try {
                          await authService.reautenticarComSms(
                            verificationId: vId!,
                            smsCode: code,
                          );

                          if (!context.mounted) return;

                          await authService.uptadeEmail(newEmail: _emailController.text.trim());

                          if (!context.mounted) return;
                          parentContext.read<UserProvider>().iniciarEscutaUsuario();

                          timer?.cancel();
                          if (context.mounted) Navigator.pop(context);  
                          if (parentContext.mounted) parentContext.pop(); 

                          parentContext.showSuccess('Link de confirmação enviado para o novo e-mail!');
                        } catch (e) {
                          setStateDialog(() {
                            verificandoCodigo = false;
                            erroSms = 'Código inválido ou expirado.';
                          });
                        }
                      },
                      keyboardType: TextInputType.number,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(8),
                        fieldHeight: 45,
                        fieldWidth: 35,
                        activeFillColor: Colors.white,
                        inactiveColor: Colors.grey[300],
                        selectedColor: const Color(0xFFFE645C),
                      ),
                    ),
                    if (verificandoCodigo)
                      const LinearProgressIndicator(color: Color(0xFFFE645C)),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: tempoRestante == 0 ? () => enviarSms(setStateDialog) : null,
                      child: Text(
                        tempoRestante > 0 ? 'Reenviar em ${tempoRestante}s' : 'Reenviar código',
                        style: TextStyle(color: tempoRestante > 0 ? Colors.grey : const Color(0xFFFE645C)),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    timer?.cancel();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
              ],
            );
          },
        );
      },
    ).then((_) => timer?.cancel());
  }

  Future<void> _atualizarEmailSemSenha() async {
    final localContext = context;
    try {
      setState(() => _isLoading = true);
      
      final authService = localContext.read<AuthService>();
      await authService.uptadeEmail(newEmail: _emailController.text.trim());
      
      if (!localContext.mounted) return;
      localContext.read<UserProvider>().iniciarEscutaUsuario();
      
      localContext.pop(); 
      localContext.showSuccess('Link de confirmação enviado para o novo e-mail!');
    } catch (e) {
      if (!localContext.mounted) return;
      localContext.showError('Erro ao atualizar e-mail: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _mostrarDialogoConfirmacaoSenha() async {
    final TextEditingController senhaController = TextEditingController();
    bool carregandoDialog = false;
    String? erroSenha;
    final parentContext = context;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'Confirme sua identidade',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF5D201C)),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Para sua segurança, digite sua senha atual antes de alterar o e-mail.',
                    style: TextStyle(color: Color(0xFF5D201C)),
                  ),
                  const SizedBox(height: 20),
                  NhacInputField(
                    controller: senhaController,
                    obscureText: true,
                    onChanged: (_) => setStateDialog(() => erroSenha = null),
                    hintText: 'Senha atual',
                    errorText: erroSenha,
                    validator: Validators.validarSenha,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: carregandoDialog ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: carregandoDialog
                      ? null
                      : () async {
                          if (senhaController.text.isEmpty) {
                            setStateDialog(() => erroSenha = 'A senha não pode ser vazia');
                            return;
                          }

                          setStateDialog(() {
                            carregandoDialog = true;
                            erroSenha = null;
                          });

                          try {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user != null && user.email != null) {
                              
                              final credential = EmailAuthProvider.credential(
                                email: user.email!,
                                password: senhaController.text,
                              );
                              
                              await user.reauthenticateWithCredential(credential);

                              if (!context.mounted) return;
                              final authService = parentContext.read<AuthService>();
                              
                              await authService.uptadeEmail(newEmail: _emailController.text.trim());
                              
                              if (!context.mounted) return;
                              parentContext.read<UserProvider>().iniciarEscutaUsuario();

                              if (context.mounted) Navigator.pop(context);
                              if (parentContext.mounted) parentContext.pop(); 

                              parentContext.showSuccess('Link de confirmação enviado para o novo e-mail!');
                            }
                          } catch (e) {
                            if (context.mounted) {
                              setStateDialog(() {
                                carregandoDialog = false;
                                erroSenha = e.toString();
                              });
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFE645C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: carregandoDialog
                      ? Transform.scale(
                          scale: 2.5,
                          child: Lottie.asset(
                            'assets/animations/botao_loading_nhac.json',
                            width: 60,
                            height: 60,
                            fit: BoxFit.contain,
                          ),
                        )
                      : const Text('Confirmar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isGoogleUser = currentUser?.providerData.any((info) => info.providerId == 'google.com') ?? false;

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
                        'Enviaremos um link de confirmação para o seu novo endereço de email',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28.0),
                      NhacInputField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        errorText: _erroEmail,
                        hintText: 'Email',
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
                texto: 'Continuar',
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
