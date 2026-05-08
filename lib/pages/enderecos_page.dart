import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nhac/components/botao_largo_nhac.dart';
import 'package:nhac/components/seta_voltar.dart';
import 'package:nhac/controllers/endereco_provider.dart';
import 'package:nhac/globals/ui_utils.dart';
import 'package:nhac/models/usuario/endereco_model.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnderecosPage extends StatefulWidget {
  const EnderecosPage({super.key});

  @override
  State<EnderecosPage> createState() => _EnderecosPageState();
}

class _EnderecosPageState extends State<EnderecosPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EnderecoProvider>().iniciarEscutaEnderecos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final enderecoProvider = context.watch<EnderecoProvider>();
    final enderecos = enderecoProvider.enderecos;

    return Scaffold(
      backgroundColor: const Color(0xFFFFE7E5),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
             padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SetaVoltar(),
                  const SizedBox(height: 32.0),
                  const Text(
                    'Endereços Salvos',
                    style: TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D201C),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Gerencie seus endereços para uma entrega mais rápida.',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey.shade800,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: enderecoProvider.isLoading
                  ? Center(
                      child: Lottie.asset(
                        'assets/animations/botao_loading_nhac.json',
                        width: 250,
                        height: 250,
                      ),
                    )
                  : enderecos.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          itemCount: enderecos.length,
                          itemBuilder: (context, index) {
                            return _buildAddressCard(enderecos[index]);
                          },
                        ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: BotaoLargoNhac(
                texto: 'Adicionar novo endereço',
                onPressed: () => _abrirBuscaEndereco(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _abrirBuscaEndereco(BuildContext context) {
    Navigator.push<Map<String, dynamic>>(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) {
          return const _BuscaEnderecoOverlay();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.fastOutSlowIn;
          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    ).then((result) =>{
      if (result != null) {
        _mostrarFormularioComplemento(result)
      }
    });
  
  }
  void _mostrarFormularioComplemento(Map<String, dynamic> enderecoGoogle) {
    final numeroController = TextEditingController(text: enderecoGoogle['numero']);
    final complementoController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, 
            left: 24.0,
            right: 24.0,
            top: 24.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Complete seu endereço',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D201C),
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                '${enderecoGoogle['rua']}, ${enderecoGoogle['bairro']}\n${enderecoGoogle['cidade']} - ${enderecoGoogle['estado']}',
                style: TextStyle(fontSize: 14.0, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24.0),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: numeroController,
                      keyboardType: TextInputType.number,
                      cursorColor: const Color(0xFFFF6961),
                      decoration: const InputDecoration(
                        labelText: 'Número',
                        labelStyle: TextStyle(color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFFF6961)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: complementoController,
                      textCapitalization: TextCapitalization.sentences,
                      cursorColor: const Color(0xFFFF6961),
                      decoration: const InputDecoration(
                        labelText: 'Complemento (Opcional)',
                        hintText: 'Apto, Bloco, Casa 2...',
                        labelStyle: TextStyle(color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFFF6961)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32.0),
              BotaoLargoNhac(
                texto: 'Salvar Endereço',
                onPressed: () {
                  enderecoGoogle['numero'] = numeroController.text.isEmpty ? 'S/N' : numeroController.text;
                  enderecoGoogle['complemento'] = complementoController.text;
                  
                  Navigator.pop(context); 
                  
                  _salvarEnderecoSelecionado(enderecoGoogle);
                },
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        );
      },
    );
  }

  Future<void> _salvarEnderecoSelecionado(Map<String, dynamic> result) async {
    if (!mounted) return;

    final isPrimeiroEndereco = context.read<EnderecoProvider>().enderecos.isEmpty;

    final novoEndereco = EnderecoModel(
      idDocumento: '', 
      rua: result['rua'] ?? '',
      numero: result['numero'] ?? 'S/N',
      bairro: result['bairro'] ?? '',
      cidade: result['cidade'] ?? '',
      estado: result['estado'] ?? '',
      cep: '', 
      complemento: result['complemento'] ?? '', 
      padrao: isPrimeiroEndereco,
    );

    try {
      await context.read<EnderecoProvider>().adicionarEndereco(novoEndereco);
      if (mounted) context.showSuccess('Endereço salvo com sucesso!');
    } catch (e) {
      if (mounted) context.showError('Erro ao salvar endereço.');
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/botao_loading_nhac.json',
            width: 60,
            height: 60,
          ),
          const SizedBox(height: 16),
          const Text(
            'Nenhum endereço salvo ainda.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF5D201C),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(EnderecoModel endereco) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF5D201C).withValues(alpha: 0.04),
            blurRadius: 15.0,
            offset: const Offset(0, 5),
          ),
        ],
        border: endereco.padrao
            ? Border.all(color: const Color(0xFFFE645C), width: 2)
            : Border.all(color: Colors.white, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24.0),
          onTap: () {
            if (!endereco.padrao) {
              _confirmarPadrao(endereco);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFE645C).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    endereco.bairro.toLowerCase().contains('tabalho') ||
                            endereco.complemento
                                .toLowerCase()
                                .contains('trabalho')
                        ? Icons.work_outline
                        : Icons.home_outlined,
                    color: const Color(0xFFFE645C),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                            Flexible(
                              child: Text(
                                '${endereco.rua}, ${endereco.numero}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                  color: Color(0xFF5D201C),
                              ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          if (endereco.padrao) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFE645C),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'PADRÃO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        '${endereco.bairro}, ${endereco.cidade} - ${endereco.estado}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13.0,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      if (endereco.complemento.isNotEmpty)
                        Text(
                          endereco.complemento,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12.0,
                            fontStyle: FontStyle.italic,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                    ],
                  ),
                ),
                _buildMenuButton(endereco),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(EnderecoModel endereco) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.grey),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (value) async {
        if (value == 'padrao') {
          await context
              .read<EnderecoProvider>()
              .definirComoPadrao(endereco.idDocumento);
          if (mounted) context.showSuccess('Endereço padrão atualizado!');
        } else if (value == 'editar') {
          _abrirEdicaoEndereco(endereco);
        } else if (value == 'remover') {
          _confirmarRemocao(endereco);
        }
      },
      itemBuilder: (context) => [
        if (!endereco.padrao)
          const PopupMenuItem(
            value: 'padrao',
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, size: 20),
                SizedBox(width: 8),
                Text('Definir como padrão'),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'editar',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 20, color: Colors.blue),
              SizedBox(width: 8),
              Text('Editar', style: TextStyle(color: Colors.blue)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'remover',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text('Remover', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  void _abrirEdicaoEndereco(EnderecoModel enderecoAtual) {
    final numeroController = TextEditingController(text: enderecoAtual.numero);
    final complementoController =
        TextEditingController(text: enderecoAtual.complemento);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24.0,
            right: 24.0,
            top: 24.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Editar endereço',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D201C),
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                '${enderecoAtual.rua}, ${enderecoAtual.bairro}\n${enderecoAtual.cidade} - ${enderecoAtual.estado}',
                style: TextStyle(fontSize: 14.0, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24.0),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextField(
                      controller: numeroController,
                      keyboardType: TextInputType.number,
                      cursorColor: const Color(0xFFFF6961),
                      decoration: const InputDecoration(
                        labelText: 'Número',
                        labelStyle: TextStyle(color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFFF6961)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: complementoController,
                      textCapitalization: TextCapitalization.sentences,
                      cursorColor: const Color(0xFFFF6961),
                      decoration: const InputDecoration(
                        labelText: 'Complemento (Opcional)',
                        hintText: 'Apto, Bloco, Casa 2...',
                        labelStyle: TextStyle(color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFFF6961)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32.0),
              BotaoLargoNhac(
                texto: 'Salvar Alterações',
                onPressed: () async {
                  final enderecoAtualizado = enderecoAtual.copyWith(
                    numero: numeroController.text.isEmpty
                        ? 'S/N'
                        : numeroController.text,
                    complemento: complementoController.text,
                  );

                  Navigator.pop(context);

                  try {
                    await context
                        .read<EnderecoProvider>()
                        .atualizarEndereco(enderecoAtualizado);
                    if (context.mounted) {
                      context.showSuccess('Endereço atualizado com sucesso!');
                    }
                  } catch (e) {
                    if (context.mounted) context.showError('Erro ao atualizar endereço.');
                  }
                },
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        );
      },
    );
  }

  void _confirmarPadrao(EnderecoModel endereco) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Definir como padrão?'),
        content:
            Text('Deseja que ${endereco.rua} seja seu endereço principal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context
                  .read<EnderecoProvider>()
                  .definirComoPadrao(endereco.idDocumento);
              if (mounted && context.mounted) {
                context.showSuccess('Endereço padrão atualizado!');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFE645C),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child:
                const Text('Confirmar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmarRemocao(EnderecoModel endereco) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Remover endereço?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context
                  .read<EnderecoProvider>()
                  .removerEndereco(endereco.idDocumento);
              if (mounted && context.mounted) {
                context.showSuccess('Endereço removido!');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Remover', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _BuscaEnderecoOverlay extends StatefulWidget {
  const _BuscaEnderecoOverlay();

  @override
  State<_BuscaEnderecoOverlay> createState() => _BuscaEnderecoOverlayState();
}

class _BuscaEnderecoOverlayState extends State<_BuscaEnderecoOverlay> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _sugestoes = [];
  bool _estaDigitando = false;
  bool _isLoadingSearch = false;
  Timer? _debounce;
  final Dio _dio = Dio();
  final String _googleApiKey = dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';

 void _filtrarEnderecos(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    
    if (query.isEmpty) {
      setState(() {
        _sugestoes = [];
        _estaDigitando = false;
        _isLoadingSearch = false;
      });
      return;
    }
    
    setState(() {
      _estaDigitando = true;
      _isLoadingSearch = true;
    });

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (_googleApiKey.isEmpty) {
        debugPrint('🚨 ERRO CRÍTICO: A chave do Google (API Key) está vazia!');
        debugPrint('Verifique se o arquivo .env existe e se está declarado no pubspec.yaml.');
        setState(() => _isLoadingSearch = false);
        return;
      }

      try {
        final response = await _dio.get(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json',
          queryParameters: {
            'input': query,
            'key': _googleApiKey,
            'components': 'country:br',
            'language': 'pt-BR',
          },
        );

        if (response.statusCode == 200) {
          final data = response.data;
          
          if (data['status'] == 'OK') {
            setState(() {
              _sugestoes = List<Map<String, dynamic>>.from(data['predictions'].map((p) => {
                'description': p['description'],
                'place_id': p['place_id'],
                'main_text': p['structured_formatting']?['main_text'] ?? p['description'].toString().split(',').first,
                'secondary_text': p['structured_formatting']?['secondary_text'] ?? p['description'],
              }));
              _isLoadingSearch = false;
            });
          } else {
            debugPrint('⚠️ RECUSA DO GOOGLE: Status = ${data['status']}');
            if (data.containsKey('error_message')) {
              debugPrint('Motivo detalhado: ${data['error_message']}');
            }
            
            setState(() {
              _sugestoes = [];
              _isLoadingSearch = false;
            });
          }
        }
      } catch (e) {
        debugPrint('⚠️ ERRO DE REQUISIÇÃO (Dio): $e');
        setState(() {
          _sugestoes = [];
          _isLoadingSearch = false;
        });
      }
    });
  }
  Future<void> _obterDetalhes(String placeId, String description) async {
    setState(() {
      _isLoadingSearch = true;
    });

    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/details/json',
        queryParameters: {
          'place_id': placeId,
          'key': _googleApiKey,
          'language': 'pt-BR',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'OK') {
          final result = data['result'];
          final components = result['address_components'] as List;

          String rua = '';
          String numero = '';
          String bairro = '';
          String cidade = '';
          String estado = '';

          for (var c in components) {
            final types = c['types'] as List;
            if (types.contains('route')) {
              rua = c['long_name'];
            }
            if (types.contains('street_number')) {
              numero = c['long_name'];
            }
            if (types.contains('sublocality') ||
                types.contains('sublocality_level_1') ||
                types.contains('neighborhood')) {
              bairro = c['long_name'];
            }
            if (types.contains('administrative_area_level_2')) {
              cidade = c['long_name'];
            }
            if (types.contains('administrative_area_level_1')) {
              estado = c['short_name'];
            }
          }

          if (mounted) {
            Navigator.pop(context, {
              'rua': rua,
              'numero': numero,
              'bairro': bairro,
              'cidade': cidade,
              'estado': estado,
            });
            context.showInfo(
                'Endereço "${description.split(",").first}" selecionado!');
          }
        }
      }
    } catch (e) {
      debugPrint('Erro ao obter detalhes do local: \$e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingSearch = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const SizedBox(
                      width: 24.0,
                      height: 24.0,
                      child: Icon(Icons.close, color: Color(0xFF5D201C), size: 24),
                    ),
                  ),
                  const SizedBox(height: 28.0),
                  const Text(
                    'Onde você quer receber o seu pedido?',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D201C),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  const Text(
                    'Busque pelo nome da rua e pelo número do seu endereço.',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Color(0xFF5D201C),
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  TextField(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: _filtrarEnderecos,
                    style: const TextStyle(
                      color: Color(0xFF5D201C),
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                      fontSize: 18.0,
                    ),
                    cursorColor: const Color(0xFFFF6961),
                    decoration: InputDecoration(
                      hintText: 'Nome da rua e número',
                      hintStyle: const TextStyle(color: Color(0xFFC9BCBC)),
                      filled: false,
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFFC9BCBC),
                          width: 2.0,
                        ),
                      ),
                      icon: null,
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear,
                                  size: 20, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                _filtrarEnderecos('');
                              },
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoadingSearch
                  ? _buildLoadingState()
                  : _sugestoes.isEmpty && _estaDigitando
                      ? _buildNotFound()
                      : _searchController.text.isEmpty
                          ? _buildEmptySearch()
                          : ListView.separated(
                              physics: const BouncingScrollPhysics(),
                              itemCount: _sugestoes.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(height: 1, indent: 70),
                              itemBuilder: (context, index) {
                                final item = _sugestoes[index];
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 8),
                                  leading: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                        Icons.location_on_outlined,
                                        color: Colors.grey),
                                  ),
                                  title: Text(
                                    item['main_text'].toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle:
                                      Text(item['secondary_text'].toString()),
                                  onTap: () {
                                    _obterDetalhes(
                                        item['place_id'], item['description']);
                                  },
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/botao_loading_nhac.json',
            width: 250,
            height: 250,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearch() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, size: 60, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text(
            'Digite o nome da rua ou avenida',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_outlined,
              size: 60, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text(
            'Endereço não encontrado',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
