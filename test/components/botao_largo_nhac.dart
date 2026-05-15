import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nhac/components/botoes/botao_largo_nhac.dart'; 

void main() {
  testWidgets('Deve mostrar o texto correto e responder ao clique na tela', (WidgetTester tester) async {
    bool foiClicado = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BotaoLargoNhac(
            texto: 'Avançar',
            onPressed: () {
              foiClicado = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Avançar'), findsOneWidget);

    await tester.tap(find.byType(BotaoLargoNhac));
    await tester.pump(); 

    expect(foiClicado, true);
  });
}