import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nhac/models/usuario/usuario_model.dart';
import 'package:nhac/pages/dados_pessoais_page.dart';
import 'package:nhac/controllers/user_provider.dart';
import 'package:provider/provider.dart';

class MockUserProvider extends ChangeNotifier implements UserProvider {
  @override
  UsuarioModel? get usuario => UsuarioModel(
        uid: '123',
        nome: 'Usuario Teste',
        email: 'teste@google.com',
        fotoUrl: '',
        telefone: '11999999999',
      );

  @override
  Future<void> iniciarEscutaUsuario() async {}
  @override
  void limparUsuario() {}
  @override
  bool get hasListeners => false;

  @override
  Future<void> atualizarFotoPerfil(File imagem) async {}

  @override
  Future<void> carregarDadosUsuario() {
    throw UnimplementedError();
  }
}

void main() {
  testWidgets('Deve mostrar ícone de cadeado e desabilitar clique para usuário Google', (WidgetTester tester) async {

    final mockProvider = MockUserProvider();

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<UserProvider>.value(
          value: mockProvider,
          child: const DadosPessoaisPage(isGoogleUserOverride: true),
        ),
      ),
    );

    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('teste@google.com'), findsOneWidget);

    expect(find.byIcon(Icons.lock_outline), findsAtLeastNWidgets(1));


    final emailItem = find.ancestor(
      of: find.text('E-mail'),
      matching: find.byType(InkWell),
    );
    
    final lockIcon = find.descendant(
      of: emailItem,
      matching: find.byIcon(Icons.lock_outline),
    );
    
    expect(lockIcon, findsOneWidget);

    final inkWell = tester.widget<InkWell>(emailItem);
    expect(inkWell.onTap, isNull);
  });

  testWidgets('Deve mostrar ícone de seta e habilitar clique para usuário comum', (WidgetTester tester) async {
    final mockProvider = MockUserProvider();

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<UserProvider>.value(
          value: mockProvider,
          child: const DadosPessoaisPage(isGoogleUserOverride: false),
        ),
      ),
    );

    final emailItem = find.ancestor(
      of: find.text('E-mail'),
      matching: find.byType(InkWell),
    );
    
    final arrowIcon = find.descendant(
      of: emailItem,
      matching: find.byIcon(Icons.arrow_forward_ios),
    );
    
    expect(arrowIcon, findsOneWidget);

    final inkWell = tester.widget<InkWell>(emailItem);
    expect(inkWell.onTap, isNotNull);
  });
}
