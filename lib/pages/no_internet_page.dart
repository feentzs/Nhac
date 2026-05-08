import 'package:flutter/material.dart';
import 'package:nhac/components/botao_largo_nhac.dart';
import 'package:nhac/services/connectivity_service.dart';
import 'package:provider/provider.dart';

class NoInternetPage extends StatelessWidget {
  const NoInternetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Image.asset(
                'assets/nhac-logo.png',
                height: 120,
              ),
              const SizedBox(height: 48),
              const Icon(
                Icons.wifi_off_rounded,
                size: 80,
                color: Color(0xFFFE645C),
              ),
              const SizedBox(height: 24),
              const Text(
                'Ops! Sem conexão',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D201C),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Parece que você está sem internet. Verifique sua conexão para continuar pedindo no Nhac.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF666666),
                ),
              ),
              const Spacer(),
              BotaoLargoNhac(
                texto: 'Tentar Novamente',
                onPressed: () async {
                  final service = Provider.of<ConnectivityService>(context, listen: false);
                  await service.checkConnection();
                                                        if(!context.mounted) return;

                  
                  if (service.isOnline) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Conexão restabelecida!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ainda sem conexão. Tente novamente.'),
                        backgroundColor: Color(0xFFFE645C),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
