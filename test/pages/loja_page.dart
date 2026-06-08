import 'package:flutter_test/flutter_test.dart';
import 'package:nhac/models/loja/lojas.dart';

void main() {
  
  group('LojasModel Tests (QA Rigoroso)', () {
    test('Deve mapear corretamente quando todos os campos do Firestore estiverem perfeitos', () {
      final mockMap = {
        'nome': 'Pizzaria Napoli',
        'categoria': 'Pizza',
        'is_aberto': true, 
        'descricao': 'A melhor pizza',
        'imagem_url': 'http://img.com/pizza.jpg',
        'dados_operacionais': {
          'taxa_entrega_base': 5.50,
          'tempo_entrega_min': 30,
          'tempo_entrega_max': 45,
          'avaliacao_media': 4.8,
          'total_avaliacoes': 200
        }
      };

      final loja = LojasModel.fromMap(mockMap, 'loja-123');

      expect(loja.uid, 'loja-123');
      expect(loja.nome, 'Pizzaria Napoli');
      expect(loja.isAberto, true);
      expect(loja.dadosOperacionais.taxaEntregaBase, 5.50);
    });

    test('Deve aplicar fallbacks e não quebrar se o Firestore mandar dados incompletos ou chaves antigas', () {
      final mockCorrompido = {
        'nome': 'Loja Fantasma',
        'isAberto': true, 
      };

      final loja = LojasModel.fromMap(mockCorrompido, 'loja-404');

      expect(loja.nome, 'Loja Fantasma');
      expect(loja.isAberto, true); 
      expect(loja.descricao, ''); 
      expect(loja.dadosOperacionais.avaliacaoMedia, 0.0); 
    });
  });
}