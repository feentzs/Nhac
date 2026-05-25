import 'package:flutter_test/flutter_test.dart';
import 'package:nhac/models/usuario/carrinho_model.dart';

void main() {
  group('CartModel Tests', () {
    test('Deve converter um Map para CartModel corretamente', () {
      final mockMap = {
        'id_produto': 'produto-456',
        'imagem_url': 'http://site.com/hamburguer.jpg',
        'nome': 'Super Nhac Bacon',
        'preco': 35.90,
        'quantidade': 2,
      };

      final itemCarrinho = CarrinhoModel.fromMap(mockMap, 'doc-carrinho-789');

      expect(itemCarrinho.idDocumento, 'doc-carrinho-789');
      expect(itemCarrinho.idProduto, 'produto-456');
      expect(itemCarrinho.nome, 'Super Nhac Bacon');
      expect(itemCarrinho.preco, 35.90);
      expect(itemCarrinho.quantidade, 2);
    });

    test('Deve usar valores por defeito quando faltarem dados', () {
      final itemVazio = CarrinhoModel.fromMap(const {}, 'doc-vazio');

      expect(itemVazio.idProduto, '');
      expect(itemVazio.quantidade, 0);
      expect(itemVazio.preco, 0.0);
    });

    test('Deve converter CartModel para Map (para gravar no Firebase)', () {
      final itemCarrinho = CarrinhoModel(
        idDocumento: 'doc-carrinho-789',
        idProduto: 'produto-456',
        imagemUrl: 'url.jpg',
        nome: 'Super Nhac Bacon',
        preco: 35.90,
        quantidade: 3,
        lojaId: 'id22'
      );

      final map = itemCarrinho.toMap();

      expect(map['id_produto'], 'produto-456');
      expect(map['quantidade'], 3);
      expect(map['preco'], 35.90);
      expect(map.containsKey('idDocumento'), false); 
    });
  });
}