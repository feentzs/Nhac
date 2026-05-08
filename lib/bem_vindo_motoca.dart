import 'package:flutter/material.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:nhac/components/botao_nhac.dart';

@NowaGenerated()
class BemVindoMotoca extends StatelessWidget {
  @NowaGenerated({'loader': 'auto-constructor'})
  const BemVindoMotoca({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        appBar: null,
        extendBody: true,
        body: Stack(
          fit: StackFit.expand,
          alignment: const Alignment(0.0, 0.0),
          children: [
            const Positioned.fill(
              child: Image(
                image: AssetImage('assets/motoca-vindo.png'),
                fit: BoxFit.cover,
              ),
            ),
            const Positioned(
              top: 37.0,
              left: 23.0,
              width: 132.0,
              height: 49.0,
              child: Image(
                image: AssetImage('assets/nhac-branco.png'),
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 42.0,
              left: 215.0,
              height: 40.0,
              width: 172.0,
              child: GestureDetector(
                onTap: () {
                  context.go('/home-page');
                },
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/home-page');
                  },
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll<Color?>(
                      Color(0x664C4C4C),
                    ),
                    foregroundColor: WidgetStatePropertyAll<Color?>(null),
                    shadowColor: WidgetStatePropertyAll<Color?>(
                      Color(0x00ffffff),
                    ),
                    elevation: WidgetStatePropertyAll<double?>(null),
                    side: WidgetStatePropertyAll<BorderSide?>(null),
                    shape: WidgetStatePropertyAll<RoundedRectangleBorder?>(
                      null,
                    ),
                  ),
                  child: const Text(
                    '       Para Clientes',
                    style: TextStyle(
                      color: Color(0xCCFFFFFF),
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                    ),
                    textAlign: TextAlign.start,
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ),
            ),
            const Positioned(
              top: 55.5,
              left: 346.0,
              width: 15.0,
              height: 15.0,
              child: Image(
                image: AssetImage('assets/Arrow right (4).png'),
                fit: BoxFit.cover,
              ),
            ),
            const Positioned(
              top: 572.0,
              left: 12.0,
              width: 391.0,
              height: 215.0,
              child: Text(
                'Abra o app. \nAcelere pela cidade. \nFaça o nhac acontecer.',
                style: TextStyle(
                  fontSize: 35.0,
                  color: Color(0xFFFFFFFF),
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.25,
                  height: 1.2,
                ),
              ),
            ),
            const Positioned(
              top: 738.0,
              left: 21.0,
              height: 49.0,
              width: 351.0,
              child: BotaoNhac(),
            ),
          ],
        ),
      ),
    );
  }
}
