import 'package:cloud_firestore/cloud_firestore.dart';

class UsuarioModel {
  final String uid;
  final String nome;
  final String email;
  final String fotoUrl;
  final String cpf;
  final String telefone;
  final Timestamp? criadoEm;
  final Timestamp? ultimoLogin;
  final bool ativo;
  final String? fcmToken; 

  UsuarioModel({
    required this.uid,
    required this.nome,
    required this.email,
    required this.fotoUrl,
    required this.telefone,
    this.cpf = '',
    this.criadoEm,
    this.ultimoLogin,
    this.ativo = true,
    this.fcmToken, 
  });

  UsuarioModel copyWith({
    String? uid,
    String? nome,
    String? email,
    String? fotoUrl,
    String? cpf,
    String? telefone,
    Timestamp? criadoEm,
    Timestamp? ultimoLogin,
    bool? ativo,
    String? fcmToken,
  }) =>
      UsuarioModel(
        uid: uid ?? this.uid,
        nome: nome ?? this.nome,
        email: email ?? this.email,
        fotoUrl: fotoUrl ?? this.fotoUrl,
        cpf: cpf ?? this.cpf,
        telefone: telefone ?? this.telefone,
        criadoEm: criadoEm ?? this.criadoEm,
        ultimoLogin: ultimoLogin ?? this.ultimoLogin,
        ativo: ativo ?? this.ativo,
        fcmToken: fcmToken ?? this.fcmToken,
      );

  factory UsuarioModel.fromMap(Map<String, dynamic> map, String id) {
    return UsuarioModel(
      uid: id,
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      fotoUrl: map['foto_url'] ?? '',
      telefone: map['telefone'] ?? '',
      cpf: map['cpf'] ?? '',
      criadoEm: map['criado_em'] is Timestamp 
          ? map['criado_em'] 
          : (map['criado_em'] is int ? Timestamp.fromMillisecondsSinceEpoch(map['criado_em']) : null),
      ultimoLogin: map['ultimo_login'] is Timestamp 
          ? map['ultimo_login'] 
          : (map['ultimo_login'] is int ? Timestamp.fromMillisecondsSinceEpoch(map['ultimo_login']) : null),
      ativo: map['ativo'] ?? true,
      fcmToken: map['fcmToken'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'email': email,
      'foto_url': fotoUrl,
      'cpf': cpf,
      'telefone': telefone,
      'criado_em': criadoEm ?? FieldValue.serverTimestamp(),
      'ultimo_login': ultimoLogin ?? FieldValue.serverTimestamp(),
      'ativo': ativo,
      if (fcmToken != null) 'fcmToken': fcmToken,
    };
  }
}
