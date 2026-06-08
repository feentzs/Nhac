import 'package:flutter_test/flutter_test.dart';
import 'package:nhac/models/usuario/carrinho_model.dart';

void main() {
  group('CarrinhoModel Unit Tests', () {
    test('fromMap com dados completos deve mapear corretamente', () {
      final mockMap = {
        'id_produto': 'p-123',
        'loja_id': 'l-456',
        'imagem_url': 'http://img.com/p.png',
        'nome': 'Pizza',
        'preco': 50.0,
        'quantidade': 2,
      };

      final item = CarrinhoModel.fromMap(mockMap, 'doc-456');

      expect(item.idDocumento, 'doc-456');
      expect(item.idProduto, 'p-123');
      expect(item.lojaId, 'l-456');
      expect(item.nome, 'Pizza');
      expect(item.preco, 50.0);
      expect(item.quantidade, 2);
    });

    test('fromMap com dados ausentes deve usar valores padrão', () {
      final item = CarrinhoModel.fromMap(const {}, 'id-vazio');

      expect(item.idProduto, '');
      expect(item.lojaId, '');
      expect(item.nome, '');
      expect(item.preco, 0.0);
      expect(item.quantidade, 0);
    });

    test('fromMap com dados corrompidos deve lidar com erros de tipo', () {
      final mockMap = {
        'preco': '50.0', // String
        'quantidade': '2', // String
      };

      expect(() => CarrinhoModel.fromMap(mockMap, 'id-corrompido'), returnsNormally);
      final item = CarrinhoModel.fromMap(mockMap, 'id-corrompido');
      expect(item.preco, 50.0);
      expect(item.quantidade, 2);
    });

    test('toMap deve gerar o Map correto', () {
      final item = CarrinhoModel(
        idDocumento: 'd1',
        idProduto: 'p1',
        lojaId: 'l1',
        imagemUrl: 'url',
        nome: 'Teste',
        preco: 10.0,
        quantidade: 1,
      );

      final map = item.toMap();

      expect(map['id_produto'], 'p1');
      expect(map['loja_id'], 'l1');
      expect(map['preco'], 10.0);
      expect(map['quantidade'], 1);
      expect(map.containsKey('idDocumento'), false);
    });
  });
}
