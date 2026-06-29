import 'package:flutter_test/flutter_test.dart';
import 'package:nhac/models/produto/produtos.dart';

void main() {
  group('ProdutosModel Unit Tests (Refactored for REST)', () {
    test('fromMap com dados completos deve mapear corretamente', () {
      final mockMap = {
        'id': 'p-1',
        'nome': 'Hamburguer',
        'preco': 20.0,
        'categoriaMenu': 'Lanches',
      };

      final produto = ProdutosModel.fromMap(mockMap);

      expect(produto.id, 'p-1');
      expect(produto.preco, 20.0);
    });
  });
}
