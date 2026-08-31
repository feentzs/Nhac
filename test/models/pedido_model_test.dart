import 'package:flutter_test/flutter_test.dart';
import 'package:nhac/models/pedido_model.dart';
import 'package:nhac/models/usuario/endereco_model.dart';
import 'package:nhac/models/usuario/carrinho_model.dart';

void main() {
  group('PedidoModel Tests', () {
    final mockEndereco = EnderecoModel(
      id: 'end1',
      rua: 'Rua das Flores',
      numero: '123',
      bairro: 'Centro',
      cidade: 'São Paulo',
      estado: 'SP',
      cep: '01000-000',
      isPadrao: true,
    );

    final mockCartItem = CartItemModel(
      produtoId: 'prod1',
      nome: 'Hambúrguer',
      imagemUrl: 'url',
      preco: 25.0,
      lojaId: 'loja1',
      quantidade: 2,
    );

    test('deve criar um PedidoModel com cupomId e serializar para Map', () {
      final pedido = PedidoModel(
        usuarioId: 'user123',
        lojaId: 'loja456',
        valorTotal: 55.0,
        taxaFrete: 5.0,
        formaPagamento: 'Dinheiro',
        trocoPara: 100.0,
        observacao: 'Sem cebola',
        cupomId: 'cupom789',
        enderecoEntrega: mockEndereco,
        itens: [mockCartItem],
      );

      final map = pedido.toMap();

      expect(map['lojaId'], 'loja456');
      expect(map['formaPagamento'], 'Dinheiro');
      expect(map['trocoPara'], 100.0);
      expect(map['observacao'], 'Sem cebola');
      expect(map['cupomId'], 'cupom789'); // Verifica a inclusão do cupomId no Map
      expect(map['enderecoEntrega']['rua'], 'Rua das Flores');
      expect(map['itens'].length, 1);
      expect(map['itens'][0]['produtoId'], 'prod1');
    });

    test('deve desserializar de um Map corretamente, incluindo cupomId e atributos de checkout', () {
      final jsonMap = {
        'id': 'pedido999',
        'usuarioId': 'user123',
        'lojaId': 'loja456',
        'valorTotal': 55.0,
        'taxaFrete': 5.0,
        'formaPagamento': 'Cartão',
        'observacao': 'Sem cebola',
        'cupomId': 'cupom789',
        'enderecoEntrega': mockEndereco.toMap(),
        'itens': [mockCartItem.toMap()],
        'status': 'PENDENTE',
        'criadoEm': '2026-08-18T10:00:00Z',
      };

      final pedido = PedidoModel.fromMap(jsonMap);

      expect(pedido.id, 'pedido999');
      expect(pedido.usuarioId, 'user123');
      expect(pedido.lojaId, 'loja456');
      expect(pedido.cupomId, 'cupom789');
      expect(pedido.status, 'PENDENTE');
      expect(pedido.itens.first.quantidade, 2);
    });

    test('não deve incluir cupomId no toMap se for nulo', () {
      final pedidoSemCupom = PedidoModel(
        usuarioId: 'user123',
        lojaId: 'loja456',
        valorTotal: 50.0,
        taxaFrete: 0.0,
        formaPagamento: 'PIX',
        enderecoEntrega: mockEndereco,
        itens: [],
      );

      final map = pedidoSemCupom.toMap();

      expect(map.containsKey('cupomId'), isFalse);
    });
  });
}
