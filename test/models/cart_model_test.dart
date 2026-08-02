import 'package:flutter_test/flutter_test.dart';
import 'package:nhac/models/usuario/carrinho_model.dart';

void main() {
  group('CartItemModel Unit Tests (Refactored for REST)', () {
    test('fromMap deve mapear corretamente (camelCase)', () {
      final mockMap = {
        'produtoId': 'p-123',
        'imagemUrl': 'http://img.com/p.png',
        'nome': 'Pizza',
        'precoHistorico': 50.0,
        'quantidade': 2,
      };

      final item = CartItemModel.fromMap(mockMap);

      expect(item.produtoId, 'p-123');
      expect(item.nome, 'Pizza');
      expect(item.preco, 50.0);
      expect(item.quantidade, 2);
    });

    test('toMap deve gerar o Map correto (camelCase)', () {
      final item = CartItemModel(
        produtoId: 'p1',
        imagemUrl: 'url',
        nome: 'Teste',
        preco: 10.0,
        lojaId: 'loja-A',
        quantidade: 1,
      );

      final map = item.toMap();

      expect(map['produtoId'], 'p1');
      expect(map['precoHistorico'], 10.0);
      expect(map['quantidade'], 1);
    });
  });
}
