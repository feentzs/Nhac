import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nhac/pages/search_page.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  Widget createWidgetUnderTest() {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => const MaterialApp(
        home: SearchPage(),
      ),
    );
  }

  testWidgets('SearchPage deve renderizar o campo de busca e aceitar input', (tester) async {
    // Nota: SearchPage tenta usar FirebaseFirestore no initState ou didUpdateWidget
    // Para um teste de UI "Headless" puro, deveríamos injetar o Firestore ou usar um mock.
    // Como o foco é garantir que a árvore de widgets não quebra (LateInitializationError, etc):
    
    // Vamos apenas verificar se os componentes básicos de UI estão lá.
    // O teste pode falhar se o Firebase não estiver inicializado e for chamado no build.
    
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); // Não pumpAndSettle por causa de animações infinitas/longas

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Procurar'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Pizza');
    expect(find.text('Pizza'), findsOneWidget);
  });
}
