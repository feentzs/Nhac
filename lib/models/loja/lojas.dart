import 'package:nhac/utils/safe_parse_helpers.dart';

class LojasModel {
  final String id; 
  final String nome;
  final String categoria;
  final String descricao;
  final String imagemUrl;
  
  final bool _isAbertoFlag; 

  final DadosOperacionais? dadosOperacionais;
  final EnderecoLoja? endereco;
  final HorariosLoja? horarios; 

  LojasModel({
    required this.id,
    required this.nome,
    required this.categoria,
    this.descricao = '',
    this.imagemUrl = '',
    bool isAberto = true,
    this.dadosOperacionais,
    this.endereco,
    this.horarios,
  }) : _isAbertoFlag = isAberto;

  bool get isAberto {
    if (!_isAbertoFlag) return false;
    if (horarios == null) return true;

    final now = DateTime.now();
    final weekDay = now.weekday; // 1 = Monday
    String horarioHoje = 'Fechado';
    switch (weekDay) {
      case 1: horarioHoje = horarios!.segunda; break;
      case 2: horarioHoje = horarios!.terca; break;
      case 3: horarioHoje = horarios!.quarta; break;
      case 4: horarioHoje = horarios!.quinta; break;
      case 5: horarioHoje = horarios!.sexta; break;
      case 6: horarioHoje = horarios!.sabado; break;
      case 7: horarioHoje = horarios!.domingo; break;
    }

    if (horarioHoje.toLowerCase() == 'fechado') return false;

    final parts = horarioHoje.split('-');
    if (parts.length != 2) return true;

    final startParts = parts[0].trim().split(':');
    final endParts = parts[1].trim().split(':');

    if (startParts.length != 2 || endParts.length != 2) return true;

    final startHour = int.tryParse(startParts[0]) ?? 0;
    final startMin = int.tryParse(startParts[1]) ?? 0;
    final endHour = int.tryParse(endParts[0]) ?? 0;
    final endMin = int.tryParse(endParts[1]) ?? 0;

    final start = startHour * 60 + startMin;
    final end = endHour * 60 + endMin;
    final current = now.hour * 60 + now.minute;

    if (start <= end) {
      return current >= start && current <= end;
    } else {
      return current >= start || current <= end;
    }
  }

  factory LojasModel.fromMap(Map<String, dynamic> map) {
    return LojasModel(
      id: map['id']?.toString() ?? '',
      nome: map['nome']?.toString() ?? '',
      categoria: map['categoria']?.toString() ?? '',
      descricao: map['descricao']?.toString() ?? '',
      imagemUrl: map['imagemUrl']?.toString() ?? '',
      isAberto: safeBool(map['isAberto'], fallback: true), 
      
      dadosOperacionais: map['dadosOperacionais'] != null 
          ? DadosOperacionais.fromMap(map['dadosOperacionais']) 
          : null,
      endereco: map['endereco'] != null 
          ? EnderecoLoja.fromMap(map['endereco']) 
          : null,
      horarios: map['horarios'] != null 
          ? HorariosLoja.fromMap(map['horarios']) 
          : null,
    );
  }
}

class DadosOperacionais {
  final double avaliacaoMedia;
  final double taxaEntregaBase;
  final int tempoEntregaMin;
  final int tempoEntregaMax;
  final int totalAvaliacoes;

  DadosOperacionais({
    required this.avaliacaoMedia,
    required this.taxaEntregaBase,
    required this.tempoEntregaMin,
    required this.tempoEntregaMax,
    required this.totalAvaliacoes,
  });

  factory DadosOperacionais.fromMap(Map<String, dynamic> map) {
    return DadosOperacionais(
      avaliacaoMedia: num.tryParse(map['avaliacaoMedia']?.toString() ?? '0')?.toDouble() ?? 0.0,
      taxaEntregaBase: num.tryParse(map['taxaEntregaBase']?.toString() ?? '0')?.toDouble() ?? 0.0,
      tempoEntregaMin: safeInt(map['tempoEntregaMin']),
      tempoEntregaMax: safeInt(map['tempoEntregaMax']),
      totalAvaliacoes: safeInt(map['totalAvaliacoes']),
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

class HorariosLoja {
  final String domingo;
  final String segunda;
  final String terca;
  final String quarta;
  final String quinta;
  final String sexta;
  final String sabado;

  HorariosLoja({
    this.domingo = 'Fechado',
    this.segunda = 'Fechado',
    this.terca = 'Fechado',
    this.quarta = 'Fechado',
    this.quinta = 'Fechado',
    this.sexta = 'Fechado',
    this.sabado = 'Fechado',
  });

  factory HorariosLoja.fromMap(Map<String, dynamic> map) {
    return HorariosLoja(
      domingo: map['domingo']?.toString() ?? 'Fechado',
      segunda: map['segunda']?.toString() ?? 'Fechado',
      terca: map['terca']?.toString() ?? 'Fechado',
      quarta: map['quarta']?.toString() ?? 'Fechado',
      quinta: map['quinta']?.toString() ?? 'Fechado',
      sexta: map['sexta']?.toString() ?? 'Fechado',
      sabado: map['sabado']?.toString() ?? 'Fechado',
    );
  }
}
