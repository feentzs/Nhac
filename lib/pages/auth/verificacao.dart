import 'package:flutter/material.dart';
import 'package:nhac/components/seta_voltar.dart';
import 'dart:async';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_svg/flutter_svg.dart';

@NowaGenerated()
class Verificacao extends StatefulWidget {
  @NowaGenerated({'loader': 'auto-constructor'})
  const Verificacao({super.key, required this.email});

  final String email;

  @override
  State<Verificacao> createState() {
    return _VerificacaoState();
  }
}

@NowaGenerated()
class _VerificacaoState extends State<Verificacao> {
  int _tempoRestante = 60;

  bool _podeReenviar = false;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _iniciarTimer();
  }

  void _iniciarTimer() {
    setState(() {
      _tempoRestante = 60;
      _podeReenviar = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_tempoRestante > 0) {
        setState(() {
          _tempoRestante--;
        });
      } else {
        setState(() {
          _podeReenviar = true;
        });
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final corAtual =
        _podeReenviar ? const Color(0xFFFF6961) : const Color(0xFF5D201C);
    final textoAtual = _podeReenviar
        ? 'Remandar código por email'
        : 'Reenviar código em 00:${_tempoRestante.toString().padLeft(2, '0')}';
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const SetaVoltar(),
              const SizedBox(height: 18.0),
                const Text(
                  'Verifique seu email',
                  style: TextStyle(
                    fontSize: 28.0,
                    color: Color(0xFF5D201C),
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text.rich(
                  TextSpan(
                    text: 'Insira o código enviado para ',
                    style: const TextStyle(
                      color: Color(0x995D201C),
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(
                        text: widget.email,
                        style: const TextStyle(
                          color: Color(0xFF5D201C),
                          fontWeight: FontWeight.w900,
                          fontSize: 16.0,
                        ),
                      ),
                      const TextSpan(
                        text:
                            '. O email pode demorar até 1 minuto para chegar.',
                      ),
                    ],
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 32.0),
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  pinTheme: PinTheme(
                    inactiveFillColor: const Color(0x33C9BCBC),
                    activeFillColor: const Color(0x33C9BCBC),
                    selectedFillColor: const Color(0x33C9BCBC),
                    inactiveColor: Colors.transparent,
                    activeColor: Colors.transparent,
                    selectedColor: Colors.transparent,
                    borderWidth: 1.0,
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(10.0),
                    fieldWidth: 45.0,
                    fieldHeight: 55.0,
                  ),
                  onChanged: (value) {},
                  onCompleted: (value) {
                    final router = GoRouter.of(context);
                    final shouldGoToCadastro =
                        widget.email.trim() == 'quemeessemano@gmail.com';
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (!mounted) {
                        return;
                      }
                      if (shouldGoToCadastro) {
                        router.push('/cadastro/nome');
                      } else {
                        router.go('/home-page');
                      }
                    });
                  },
                  autoFocus: true,
                  enableActiveFill: true,
                  cursorColor: const Color(0xFFFF6961),
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    const SizedBox(width: 8.0),
                    GestureDetector(
                      onTap: _podeReenviar ? _iniciarTimer : null,
                      child: SvgPicture(
                        const SvgAssetLoader('assets/reload.svg'),
                        width: 14.0,
                        height: 14.0,
                        colorFilter: ColorFilter.mode(
                          corAtual,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    GestureDetector(
                      onTap: _podeReenviar ? _iniciarTimer : null,
                      child: Text(
                        textoAtual,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: corAtual,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        GoRouter.of(context).push('/continuar_senha');
                      },
                      child: const Text(
                        'Entrar com a senha',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Color(0xFFFF6961),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
