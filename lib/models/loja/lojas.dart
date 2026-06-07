import 'package:cloud_firestore/cloud_firestore.dart';

class LojasModel {
  final String uid;
  final String nome;
  final String categoria;
  final bool isAberto;
  final String descricao;
  final String imagemUrl;
  final Map<String, String> horarios;
  final Timestamp? criadoEm;

  // Os nossos blocos agrupados!
  final DadosOperacionais dadosOperacionais;
  final EnderecoLoja endereco;
  final Geolocalizacao geolocalizacao;

  LojasModel({
    required this.uid,
    required this.nome,
    required this.categoria,
    required this.isAberto,
    this.descricao = '',
    this.imagemUrl = '',
    required this.horarios,
    this.criadoEm,
    required this.dadosOperacionais,
    required this.endereco,
    required this.geolocalizacao,
  });

  factory LojasModel.fromMap(Map<String, dynamic> map, String uid) {
    return LojasModel(
      uid: uid,
      nome: map['nome']?.toString() ?? '',
      categoria: map['categoria']?.toString() ?? '',
      isAberto: map['is_aberto'] == true,
      descricao: map['descricao']?.toString() ?? '',
      imagemUrl: map['imagem_url']?.toString() ?? '',
      horarios: Map<String, String>.from(map['horarios'] ?? {}),
      criadoEm: map['criado_em'] as Timestamp?,
      // Mapeando os blocos internos:
      dadosOperacionais: DadosOperacionais.fromMap(map['dados_operacionais'] ?? {}),
      endereco: EnderecoLoja.fromMap(map['endereco'] ?? {}),
      geolocalizacao: Geolocalizacao.fromMap(map['geolocalizacao'] ?? {}),
    );
  }
}

// --- SUBCLASSES ---

class DadosOperacionais {
  final double taxaEntregaBase;
  final int tempoEntregaMin;
  final int tempoEntregaMax;
  final double avaliacaoMedia;
  final int totalAvaliacoes;

  DadosOperacionais({
    required this.taxaEntregaBase,
    required this.tempoEntregaMin,
    required this.tempoEntregaMax,
    required this.avaliacaoMedia,
    required this.totalAvaliacoes,
  });

  factory DadosOperacionais.fromMap(Map<String, dynamic> map) {
    return DadosOperacionais(
      taxaEntregaBase: num.tryParse(map['taxa_entrega_base']?.toString() ?? '0')?.toDouble() ?? 0.0,
      tempoEntregaMin: int.tryParse(map['tempo_entrega_min']?.toString() ?? '0') ?? 0,
      tempoEntregaMax: int.tryParse(map['tempo_entrega_max']?.toString() ?? '0') ?? 0,
      avaliacaoMedia: num.tryParse(map['avaliacao_media']?.toString() ?? '0')?.toDouble() ?? 0.0,
      totalAvaliacoes: int.tryParse(map['total_avaliacoes']?.toString() ?? '0') ?? 0,
    );
  }
}

class EnderecoLoja {
  final String rua;
  final String numero;
  final String cidade;
  final String estado;
  final String cep;

  EnderecoLoja({
    required this.rua,
    required this.numero,
    required this.cidade,
    required this.estado,
    required this.cep,
  });

  factory EnderecoLoja.fromMap(Map<String, dynamic> map) {
    return EnderecoLoja(
      rua: map['rua']?.toString() ?? '',
      numero: map['numero']?.toString() ?? '',
      cidade: map['cidade']?.toString() ?? '',
      estado: map['estado']?.toString() ?? '',
      cep: map['cep']?.toString() ?? '',
    );
  }
}

class Geolocalizacao {
  final double lat;
  final double lng;
  final String geohash;

  Geolocalizacao({
    required this.lat,
    required this.lng,
    required this.geohash,
  });

  factory Geolocalizacao.fromMap(Map<String, dynamic> map) {
    return Geolocalizacao(
      lat: num.tryParse(map['lat']?.toString() ?? '0')?.toDouble() ?? 0.0,
      lng: num.tryParse(map['lng']?.toString() ?? '0')?.toDouble() ?? 0.0,
      geohash: map['geohash']?.toString() ?? '',
    );
  }
}
