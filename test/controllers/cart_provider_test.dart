import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nhac/controllers/cart_provider.dart';
import 'package:nhac/repositories/cart_repository.dart';

class MockCartRepository extends Mock implements CartRepository {}

void main() {
  group('CartProvider Unit Tests (Business Logic)', () {
    late CartProvider cartProvider;
    late MockCartRepository mockRepo;

    setUp(() {
      mockRepo = MockCartRepository();
      
      when(() => mockRepo.salvarCarrinhoLocal(any())).thenAnswer((_) async => Future.value());
      when(() => mockRepo.limparCarrinho()).thenAnswer((_) async => Future.value());
      when(() => mockRepo.carregarCarrinhoLocal()).thenAnswer((_) async => []);

      cartProvider = CartProvider(
        repository: mockRepo,
      );
    });

    test('Esvaziar carrinho deve resetar todas as variáveis e chamar repositório', () async {
      await cartProvider.esvaziarCarrinho();
      
      expect(cartProvider.itens, isEmpty);
      expect(cartProvider.valorTotal, 0.0);
      expect(cartProvider.totalDeUnidades, 0);
      expect(cartProvider.observacao, '');
      verify(() => mockRepo.limparCarrinho()).called(1);
    });
  });
}
