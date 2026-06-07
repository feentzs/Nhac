import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nhac/controllers/cart_provider.dart';
import 'package:nhac/models/usuario/carrinho_model.dart';
import 'package:nhac/repository/cart_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockCartRepository extends Mock implements CartRepository {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

void main() {
  group('CartProvider Unit Tests (Business Logic)', () {
    late CartProvider cartProvider;
    late MockCartRepository mockRepo;
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;
    late MockFirebaseFirestore mockFirestore;

    setUp(() {
      mockRepo = MockCartRepository();
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();
      mockFirestore = MockFirebaseFirestore();

      when(() => mockUser.uid).thenReturn('user-123');
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      
      cartProvider = CartProvider(
        auth: mockAuth, 
        repository: mockRepo,
        firestore: mockFirestore,
      ); 
    });

    test('Limpeza de estado deve resetar todas as variáveis', () {
      cartProvider.limparCarrinhoLocal();
      
      expect(cartProvider.itens, isEmpty);
      expect(cartProvider.valorTotal, 0.0);
      expect(cartProvider.totalDeUnidades, 0);
      expect(cartProvider.observacao, '');
    });

    test('Deve impedir itens de lojas diferentes (Regra de Negócio)', () {
      // Mock para adicionarItemComQuantidade se necessário
    });
  });
}
