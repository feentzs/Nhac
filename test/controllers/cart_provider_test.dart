import 'package:flutter_test/flutter_test.dart';
import 'package:nhac/controllers/cart_provider.dart';

void main() {
  group('CartProvider Tests', () {
    
    test('Deve adicionar um item novo e calcular o valor total', () {
      final carrinho = CartProvider();

      carrinho.adicionarItem(
        idProduto: 'lanche-123',
        nome: 'Super Nhac Bacon',
        preco: 35.90,
        imagemUrl: 'url_falsa.jpg',
        lojaId: 'id22'
      );

      expect(carrinho.quantidadeItens, 1);
      expect(carrinho.valorTotal, 35.90);
      expect(carrinho.itens['lanche-123']?.nome, 'Super Nhac Bacon');
    });

    test('Deve somar a quantidade se o item já existir no carrinho', () {
      final carrinho = CartProvider();

      carrinho.adicionarItem(idProduto: 'p1', nome: 'Batata', preco: 10.0, imagemUrl: '', lojaId: 'id2');
      carrinho.adicionarItem(idProduto: 'p1', nome: 'Batata', preco: 10.0, imagemUrl: '', lojaId: 'id2');

      expect(carrinho.quantidadeItens, 1); 
      expect(carrinho.itens['p1']?.quantidade, 2); 
      expect(carrinho.valorTotal, 20.0); 
    });

    test('Deve esvaziar o carrinho se não existir itens', () {
      final carrinho = CartProvider();

      carrinho.adicionarItem(idProduto: 'p1', nome: 'Batata', preco: 10.0, imagemUrl: '', lojaId: 'id2');

      carrinho.removerItem('p1');

      expect(carrinho.quantidadeItens, 0);
      expect(carrinho.valorTotal, 0);
      expect(carrinho.itens.length, 0);
    });

    test('Deve esvaziar o carrinho quando função de esvaziar ser chamada', (){
        final carrinho = CartProvider();

      carrinho.adicionarItem(idProduto: 'p1', nome: 'Batata', preco: 10.0, imagemUrl: '', lojaId: 'id1');
      carrinho.adicionarItem(idProduto: 'p1', nome: 'Batata', preco: 10.0, imagemUrl: '', lojaId: 'id1');

    carrinho.esvaziarCarrinho();


    expect(carrinho.quantidadeItens, 0);
      expect(carrinho.valorTotal, 0);
      expect(carrinho.itens.length, 0);


    });

  });
}