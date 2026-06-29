import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nhac/controllers/user_provider.dart';
import 'package:nhac/repositories/user_repository.dart';

class MockUserRepository extends Mock implements UserRepository {}
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}

void main() {
  group('UserProvider Unit Tests', () {
    late UserProvider userProvider;
    late MockUserRepository mockRepo;
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;

    setUp(() {
      mockRepo = MockUserRepository();
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();

      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('user-123');
      
      userProvider = UserProvider(
        auth: mockAuth,
        repository: mockRepo,
      );
    });

    test('limparUsuario deve resetar o usuário', () {
      userProvider.limparUsuario();
      expect(userProvider.usuario, isNull);
    });
  });
}
