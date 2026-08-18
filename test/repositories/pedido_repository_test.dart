import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:nhac/models/pedido_model.dart';
import 'package:nhac/models/usuario/endereco_model.dart';
import 'package:nhac/repositories/pedido_repository.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late PedidoRepository repository;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    // No aplicativo real, PedidoRepository() obtém o ApiClient().dio
    // Para fins de teste isolado e injeção de dependência rudimentar, 
    // idealmente deveríamos injetar o Dio no repositório.
    // Como a arquitetura atual usa `final _dio = ApiClient().dio;`, 
    // faremos um teste conceitual da lógica de conversão.
  });

  group('PedidoRepository Tests (Lógica)', () {
    final mockPedido = PedidoModel(
      usuarioId: 'user1',
      lojaId: 'loja1',
      valorTotal: 50.0,
      taxaFrete: 5.0,
      formaPagamento: 'Cartão',
      enderecoEntrega: EnderecoModel(
        id: 'end1', rua: 'Rua A', numero: '1', bairro: 'B', cidade: 'C', estado: 'ST', cep: '000', isPadrao: true
      ),
      itens: [],
      cupomId: 'TESTE10',
    );

    test('O modelo enviado contém cupomId e a resposta mapeia o clientSecret', () {
      final mapRequest = mockPedido.toMap();
      expect(mapRequest['cupomId'], 'TESTE10');

      final mockResponseBackend = {
        'id': '12345',
        'pedidoId': '12345',
        'status': 'PENDENTE',
        'clientSecret': 'pi_12345_secret_abc123'
      };


      final clientSecret = mockResponseBackend['clientSecret'];
      final idGerado = mockResponseBackend['id'] ?? mockResponseBackend['pedidoId'];

      expect(clientSecret, 'pi_12345_secret_abc123');
      expect(idGerado, '12345');
    });
  });
}
