import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nhac/controllers/user_provider.dart';
import 'package:nhac/repositories/user_repository.dart';
import 'package:nhac/services/auth_service.dart';

class MockUserRepository extends Mock implements UserRepository {}
class MockAuthService extends Mock implements AuthService {}

void main() {
  group('UserProvider Unit Tests', () {
    late UserProvider userProvider;
    late MockUserRepository mockRepo;
    late MockAuthService mockAuth;

    setUp(() {
      mockRepo = MockUserRepository();
      mockAuth = MockAuthService();

      when(() => mockAuth.usuarioId).thenReturn('user-123');
      
      userProvider = UserProvider(
        authService: mockAuth,
        repository: mockRepo,
      );
    });

    test('limparUsuario deve resetar o usuário', () {
      userProvider.limparUsuario();
      expect(userProvider.usuario, isNull);
    });
  });
}
