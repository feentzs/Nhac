import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:nhac/components/botoes/botao_nhac.dart';

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
          children: [
            const Positioned.fill(
              child: Image(image: AssetImage('assets/um cara em cima da moto de delivery entregando uma pizza para um morador.jpg'), fit: BoxFit.cover),
            ),
            Positioned(
              top: 37.h,
              left: 23.w,
              width: 132.w,
              height: 49.h,
              child: const Image(image: AssetImage('assets/nhac-branco.png'), fit: BoxFit.contain),
            ),
            Positioned(
              top: 42.h,
              left: 215.w,
              height: 40.h,
              width: 172.w,
              child: GestureDetector(
                onTap: () => context.go('/home-page'),
                child: ElevatedButton(
                  onPressed: () => context.go('/home-page'),
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll<Color?>(Color(0x664C4C4C)),
                    shadowColor: WidgetStatePropertyAll<Color?>(Color(0x00ffffff)),
                  ),
                  child: Text('       Para Clientes', style: TextStyle(color: const Color(0xCCFFFFFF), fontSize: 12.sp, fontWeight: FontWeight.w600, letterSpacing: 0.1), textAlign: TextAlign.start, textDirection: TextDirection.rtl),
                ),
              ),
            ),
            Positioned(
              top: 55.5.h,
              left: 346.w,
              width: 15.w,
              height: 15.h,
              child: Icon(Icons.arrow_forward_ios, size: 14.sp, color: const Color(0xCCFFFFFF)),
            ),
            Positioned(
              top: 572.h,
              left: 12.w,
              width: 391.w,
              height: 215.h,
              child: Text(
                'Abra o app. \nAcelere pela cidade. \nFaça o nhac acontecer.',
                style: TextStyle(fontSize: 35.sp, color: const Color(0xFFFFFFFF), fontWeight: FontWeight.w600, letterSpacing: 0.25, height: 1.2),
              ),
            ),
            Positioned(
              top: 738.h,
              left: 21.w,
              height: 49.h,
              width: 351.w,
              child: const BotaoNhac(),
            ),
          ],
        ),
      ),
    );
  }
}