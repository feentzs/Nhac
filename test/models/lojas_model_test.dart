import 'package:flutter_test/flutter_test.dart';
import 'package:nhac/models/loja/lojas.dart';

void main() {
  group('LojasModel Unit Tests (Refactored for REST)', () {
    test('fromMap com dados completos deve mapear corretamente', () {
      final mockMap = {
        'id': 'l-123',
        'nome': 'Loja Nhac',
        'categoria': 'Pizza',
        'isAberto': true,
        'dadosOperacionais': {
          'avaliacaoMedia': 4.5,
          'taxaEntregaBase': 5.0,
          'tempoEntregaMin': 30,
          'tempoEntregaMax': 45,
          'totalAvaliacoes': 100,
        }
      };

      final loja = LojasModel.fromMap(mockMap);

      expect(loja.id, 'l-123');
      expect(loja.nome, 'Loja Nhac');
      expect(loja.dadosOperacionais!.avaliacaoMedia, 4.5);
    });
  });
}
