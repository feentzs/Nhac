import 'package:flutter_test/flutter_test.dart';
import 'package:nhac/models/produto/produtos.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('ProdutosModel Unit Tests', () {
    test('fromMap com dados completos deve mapear corretamente', () {
      final mockMap = {
        'loja_id': 'loja-123',
        'nome': 'Super Nhac Bacon',
        'descricao': 'Pão artesanal, carne dupla e queijo cheddar',
        'preco': 35.90,
        'categoria_menu': 'Hambúrguer',
        'imagem_url': 'http://site.com/hamburguer.jpg',
        'is_ativo': true,
        'loja_is_aberto': true,
        'peso': '500g',
        'percentual_desconto': 10,
      };

      final produto = ProdutosModel.fromMap(mockMap, 'produto-456');

      expect(produto.uid, 'produto-456');
      expect(produto.lojaId, 'loja-123');
      expect(produto.nome, 'Super Nhac Bacon');
      expect(produto.preco, 35.90);
      expect(produto.categoriaMenu, 'Hambúrguer');
      expect(produto.isAtivo, true);
      expect(produto.lojaIsAberto, true);
      expect(produto.peso, '500g');
      expect(produto.percentualDesconto, 10);
    });

    test('fromMap com dados ausentes deve usar valores padrão', () {
      final produto = ProdutosModel.fromMap(const {}, 'id-vazio');

      expect(produto.uid, 'id-vazio');
      expect(produto.nome, '');
      expect(produto.preco, 0.0);
      expect(produto.isAtivo, false); 
      expect(produto.lojaIsAberto, false); 
      expect(produto.categoriaMenu, '');
    });

    test('fromMap com dados corrompidos deve lidar com erros de tipo', () {
      final mockMap = {
        'preco': '35.90',
        'is_ativo': 1,
      };

      expect(() => ProdutosModel.fromMap(mockMap, 'id-corrompido'), returnsNormally);
    });

    test('toMap deve gerar o Map correto para o Firebase', () {
      final produto = ProdutosModel(
        uid: 'p-1',
        lojaId: 'l-1',
        nome: 'Produto Teste',
        preco: 10.0,
        categoriaMenu: 'Teste',
        isAtivo: true,
      );

      final map = produto.toMap();

      expect(map['loja_id'], 'l-1');
      expect(map['nome'], 'Produto Teste');
      expect(map['preco'], 10.0);
      expect(map['is_ativo'], true);
      expect(map['categoria_menu'], 'Teste');
      expect(map.containsKey('criado_em'), true);
    });
  });
}
