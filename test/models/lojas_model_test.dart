import 'package:flutter_test/flutter_test.dart';
import 'package:nhac/models/loja/lojas.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('LojasModel Unit Tests', () {
    test('fromMap com dados completos deve mapear corretamente', () {
      final mockMap = {
        'nome': 'Nhac Burger',
        'categoria': 'Hambúrguer',
        'is_aberto': true,
        'descricao': 'O melhor hambúrguer da cidade',
        'imagem_url': 'http://link.com/foto.png',
        'horarios': {'segunda': '08:00 - 22:00'},
        'criado_em': Timestamp.now(),
        'dados_operacionais': {
          'taxa_entrega_base': 5.0,
          'tempo_entrega_min': 30,
          'tempo_entrega_max': 45,
          'avaliacao_media': 4.8,
          'total_avaliacoes': 150,
        },
        'endereco': {
          'rua': 'Rua das Flores',
          'numero': '123',
          'cidade': 'São Paulo',
          'estado': 'SP',
          'cep': '01234-567',
        },
        'geolocalizacao': {
          'lat': -23.5505,
          'lng': -46.6333,
          'geohash': '7h3j',
        },
      };

      final loja = LojasModel.fromMap(mockMap, 'uid-123');

      expect(loja.uid, 'uid-123');
      expect(loja.nome, 'Nhac Burger');
      expect(loja.isAberto, true);
      expect(loja.dadosOperacionais.taxaEntregaBase, 5.0);
      expect(loja.endereco.rua, 'Rua das Flores');
      expect(loja.geolocalizacao.lat, -23.5505);
    });

    test('fromMap com dados ausentes deve usar valores padrão', () {
      final loja = LojasModel.fromMap(const {}, 'uid-vazio');

      expect(loja.uid, 'uid-vazio');
      expect(loja.nome, '');
      expect(loja.isAberto, false);
      expect(loja.dadosOperacionais.taxaEntregaBase, 0.0);
      expect(loja.endereco.rua, '');
      expect(loja.geolocalizacao.lat, 0.0);
    });

    test('fromMap com dados corrompidos deve lidar com erros de tipo graciosamente', () {
      final mockMap = {
        'nome': 123,
        'is_aberto': 'true',
        'dados_operacionais': {
          'taxa_entrega_base': 'grátis',
        },
      };

      expect(() => LojasModel.fromMap(mockMap, 'uid-corrompido'), returnsNormally);
      final loja = LojasModel.fromMap(mockMap, 'uid-corrompido');
      expect(loja.nome, isNot(123));
    });
  });
}
