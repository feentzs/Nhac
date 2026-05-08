import 'package:flutter/material.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:flutter/services.dart';
import 'package:nhac/components/nhac_logo.dart';
import 'package:go_router/go_router.dart';
import 'package:nhac/components/botao_nhac.dart';

@NowaGenerated()
class BemVindo extends StatefulWidget {
  @NowaGenerated({'loader': 'auto-constructor'})
  const BemVindo({super.key});

  @override
  State<BemVindo> createState() {
    return _BemVindoState();
  }
}

@NowaGenerated()
class _BemVindoState extends State<BemVindo> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(
                      width: 132.0,
                      height: 49.0,
                      child: NhacLogo(),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.push('/bem-vindo-motoca');
                      },
                      style: ButtonStyle(
                        backgroundColor: const WidgetStatePropertyAll<Color?>(
                          Color(0xFFFFF5F5),
                        ),
                        elevation: const WidgetStatePropertyAll<double?>(0.0),
                        shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Para Entregadores',
                            style: TextStyle(
                              color: Color(0xFF7C6F6F),
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 14.0,
                            color: Color(0xFF7C6F6F),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                FlexSizedBox(
                  height: 406.0,
                  child: Center(
                    child: Image.asset(
                      'assets/lanche-bem-vindo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const FlexSizedBox(
                  width: 301.1875,
                  height: 34.0,
                  child: Text(
                    'O Nhac que sua fome pedia',
                    style: TextStyle(
                      fontSize: 28.0,
                      color: Color(0xFF5D201C),
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12.0),
                const Text(
                  'Encontre os melhores restaurantes locais e peça sua comida favorita com rapidez e facilidade.',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Color(0x995D201C),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32.0),
                const SizedBox(
                  width: double.infinity,
                  height: 49.0,
                  child: BotaoNhac(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}