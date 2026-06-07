import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nhac/components/botoes/botao_largo_nhac.dart';
import 'package:lottie/lottie.dart';

void main() {
  Widget createWidgetUnderTest({
    required String texto,
    required VoidCallback aoPressionar,
    bool isLoading = false,
  }) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        home: Scaffold(
          body: BotaoLargoNhac(
            texto: texto,
            onPressed: aoPressionar,
            carregando: isLoading,
          ),
        ),
      ),
    );
  }

  testWidgets('Deve exibir o texto correto no botão', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(
      texto: 'Confirmar',
      aoPressionar: () {},
    ));
    
    expect(find.text('Confirmar'), findsOneWidget);
    expect(find.byType(Lottie), findsNothing);
  });

  testWidgets('Deve exibir loading quando carregando for true', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(
      texto: 'Confirmar',
      aoPressionar: () {},
      isLoading: true,
    ));
    
    expect(find.byType(Lottie), findsOneWidget);
    expect(find.text('Confirmar'), findsNothing);
  });

  testWidgets('Deve chamar o callback ao clicar', (tester) async {
    bool chamado = false;
    await tester.pumpWidget(createWidgetUnderTest(
      texto: 'Clique aqui',
      aoPressionar: () => chamado = true,
    ));

    await tester.tap(find.text('Clique aqui'));
    expect(chamado, isTrue);
  });
}
