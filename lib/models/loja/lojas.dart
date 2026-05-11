import 'package:cloud_firestore/cloud_firestore.dart';

class LojasModel {
  final String uid;
  final bool aberta;
  final String categoria;
  final String cep;
  final String cidade;
  final Timestamp? criadoEm;
  final String descricao;
  final String estado;
  final Map<String, String> horarios;
  final String imagemUrl;
  final double mediaAvaliacao;
  final String nome;
  final String numero;
  final String rua;
  final int totalAvaliacoes;

  LojasModel({
    required this.uid,
    required this.aberta,
    required this.categoria,
    required this.cep,
    required this.cidade,
    this.criadoEm,
    this.descricao = '',
    required this.estado,
    required this.horarios,
    this.imagemUrl = '',
    this.mediaAvaliacao = 0.0,
    required this.nome,
    required this.numero,
    required this.rua,
    this.totalAvaliacoes = 0,
  });

  LojasModel copyWith({
    String? uid,
    bool? aberta,
    String? categoria,
    String? cep,
    String? cidade,
    Timestamp? criadoEm,
    String? descricao,
    String? estado,
    Map<String, String>? horarios,
    String? imagemUrl,
    double? mediaAvaliacao,
    String? nome,
    String? numero,
    String? rua,
    int? totalAvaliacoes,
  }) =>
      LojasModel(
        uid: uid ?? this.uid,
        aberta: aberta ?? this.aberta,
        categoria: categoria ?? this.categoria,
        cep: cep ?? this.cep,
        cidade: cidade ?? this.cidade,
        descricao: descricao ?? this.descricao,
        estado: estado ?? this.estado,
        horarios: horarios ?? this.horarios,
        imagemUrl: imagemUrl ?? this.imagemUrl,
        mediaAvaliacao: mediaAvaliacao ?? this.mediaAvaliacao,
        nome: nome ?? this.nome,
        numero: numero ?? this.numero,
        rua: rua ?? this.rua,
        totalAvaliacoes: totalAvaliacoes ?? this.totalAvaliacoes,
      );

  factory LojasModel.fromMap(Map<String, dynamic> map, String uid) {
    return LojasModel(
      uid: uid,
      aberta: map['aberta'] ?? false,
      categoria: map['categoria'] ?? '',
      cep: map['cep'] ?? '',
      cidade: map['cidade'] ?? '',
      criadoEm: map['criado_em'] as Timestamp?,
      descricao: map['descricao'] ?? '',
      estado: map['estado'] ?? '',
      horarios: Map<String, String>.from(map['horarios'] ?? {}),
      imagemUrl: map['imagem_url'] ?? '',
      mediaAvaliacao: (map['media_avaliacao'] ?? 0).toDouble(),
      nome: map['nome'] ?? '',
      numero: map['numero'] ?? '',
      rua: map['rua'] ?? '',
      totalAvaliacoes: (map['total_avaliacoes'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'aberta': aberta,
      'categoria': categoria,
      'cep': cep,
      'cidade': cidade,
      'criado_em': criadoEm ?? FieldValue.serverTimestamp(),
      'descricao': descricao,
      'estado': estado,
      'horarios': horarios,
      'imagem_url': imagemUrl,
      'media_avaliacao': mediaAvaliacao,
      'nome': nome,
      'numero': numero,
      'rua': rua,
      'total_avaliacoes': totalAvaliacoes,
    };
  }
}
