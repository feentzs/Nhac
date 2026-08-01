import 'package:flutter_test/flutter_test.dart';
import 'package:nhac/models/usuario/usuario_model.dart';

void main() {
  group('UsuarioModel Unit Tests (Refactored for REST)', () {
    test('fromMap com dados completos deve mapear corretamente', () {
      final mockMap = {
        'id': 'u-1',
        'nome': 'João',
        'email': 'joao@test.com',
        'telefone': '123456789',
      };

      final usuario = UsuarioModel.fromMap(mockMap);

      expect(usuario.id, 'u-1');
      expect(usuario.nome, 'João');
    });
  });
}
