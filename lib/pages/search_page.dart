import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../models/produto/produtos.dart';
import '../models/loja/lojas.dart';
import '../components/product_card.dart';
import '../components/loading_nhac.dart';
import '../repositories/produto_repository.dart';
import '../repositories/loja_repository.dart';
import '../services/local_cache_service.dart';
import 'produto_detalhes_page.dart';
import 'loja_page.dart';

// Paleta oficial do app (ver globals/themes.dart e product_card.dart)
const Color _corPrimaria = Color(0xFFFF6961);
const Color _corTexto = Color(0xFF5D201C);
const Color _corSuperficie = Color(0xFFFFE7E5);
const Color _corAccentClaro = Color(0xFFFFF0EE);

enum _FiltroBusca { tudo, produtos, lojas }

class _ResultadoBusca {
  final List<ProdutosModel> produtos;
  final List<LojasModel> lojas;
  final Map<String, bool> lojaAberta; // lojaId -> está aberta?
  _ResultadoBusca({required this.produtos, required this.lojas, this.lojaAberta = const {}});

  bool get vazio => produtos.isEmpty && lojas.isEmpty;
}

class SearchPage extends StatefulWidget {
  final String? initialCategory;

  const SearchPage({super.key, this.initialCategory});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // Valores devem bater exatamente com a coluna `categoria_menu` do banco,
  // já que o backend filtra produtos/lojas por valor exato.
  static const _categoriasSugeridas = [
    {'nome': 'Combos', 'icon': Icons.fastfood_rounded},
    {'nome': 'Prato Principal', 'icon': Icons.restaurant_rounded},
    {'nome': 'Acompanhamento', 'icon': Icons.rice_bowl_rounded},
    {'nome': 'Sobremesas', 'icon': Icons.icecream_rounded},
    {'nome': 'Bebidas', 'icon': Icons.local_drink_rounded},
  ];

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final ProdutoRepository _produtoRepository = ProdutoRepository();
  final LojaRepository _lojaRepository = LojaRepository();

  Future<_ResultadoBusca>? _searchFuture;
  _FiltroBusca _filtro = _FiltroBusca.tudo;
  List<String> _historico = [];
  bool _temTexto = false;
  bool _focusAgendado = false;

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
    _searchController.addListener(() {
      final temTexto = _searchController.text.isNotEmpty;
      if (temTexto != _temTexto) setState(() => _temTexto = temTexto);
    });
    _searchFocus.addListener(() => setState(() {}));
    if (widget.initialCategory != null && widget.initialCategory!.isNotEmpty) {
      _searchController.text = widget.initialCategory!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _buscarPorCategoriaInicial(widget.initialCategory!);
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) FocusScope.of(context).requestFocus(_searchFocus);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }



  Future<void> _carregarHistorico() async {
    final historico = await LocalCacheService.carregarHistoricoPesquisa();
    if (mounted) setState(() => _historico = historico);
  }

  Future<void> _salvarNoHistorico(String termo) async {
    final atualizado = List<String>.from(_historico)
      ..removeWhere((t) => t.toLowerCase() == termo.toLowerCase())
      ..insert(0, termo);
    final limitado = atualizado.take(8).toList();
    setState(() => _historico = limitado);
    await LocalCacheService.salvarHistoricoPesquisa(limitado);
  }

  Future<void> _removerDoHistorico(String termo) async {
    final atualizado = List<String>.from(_historico)..remove(termo);
    setState(() => _historico = atualizado);
    await LocalCacheService.salvarHistoricoPesquisa(atualizado);
  }

  void _buscarPorCategoriaInicial(String categoria) {
    if (categoria.isEmpty) return;
    setState(() {
      _filtro = _FiltroBusca.tudo;
      _searchFuture = _produtoRepository.buscarPorCategoria(categoria).then(
        (produtos) async => _ResultadoBusca(
          produtos: produtos,
          lojas: const [],
          lojaAberta: await _statusDasLojas(produtos),
        ),
      );
    });
  }

  /// Busca o status aberta/fechada de cada loja distinta entre os produtos
  /// encontrados — usado pra impedir adicionar ao carrinho item de loja
  /// fechada direto pelos resultados da busca (antes não tinha essa checagem
  /// aqui porque a busca não sabia nada sobre a loja de cada produto).
  Future<Map<String, bool>> _statusDasLojas(List<ProdutosModel> produtos) async {
    final idsUnicos = produtos.map((p) => p.lojaId).where((id) => id.isNotEmpty).toSet();
    if (idsUnicos.isEmpty) return {};

    final entradas = await Future.wait(idsUnicos.map((id) async {
      try {
        final loja = await _lojaRepository.buscarLoja(id);
        // Se a loja não veio (ex.: endpoint não retorna lojas fechadas),
        // tratamos como fechada por segurança, e não como aberta. O mesmo
        // vale se a busca falhar — bloquear e deixar o usuário tentar de
        // novo é bem melhor do que liberar "adicionar ao carrinho" de uma
        // loja que pode estar fechada.
        return MapEntry(id, loja?.isAberto ?? false);
      } catch (_) {
        return MapEntry(id, false);
      }
    }));

    return Map.fromEntries(entradas);
  }

  /// Busca unificada: produtos por NOME + produtos por CATEGORIA (mesclados,
  /// sem duplicar) + lojas por NOME — tudo a partir do mesmo termo digitado.
  void _iniciarBusca(String termo) {
    final termoLimpo = termo.trim();
    if (termoLimpo.isEmpty) return;
    _searchController.text = termoLimpo;
    _searchFocus.unfocus();
    _salvarNoHistorico(termoLimpo);
    setState(() {
      _filtro = _FiltroBusca.tudo;
      _searchFuture = _buscarTudo(termoLimpo);
    });
  }

  Future<_ResultadoBusca> _buscarTudo(String termo) async {
    // O filtro de categoria no backend é por valor exato (ex: "Pizza"), então
    // digitar "pizza" (minúsculo) batia só na busca por nome. Aqui a gente
    // resolve o termo digitado pro nome exato da categoria quando ele
    // corresponde a uma das categorias conhecidas, senão manda como veio.
    final categoriaParaBuscar = _resolverCategoria(termo);

    final resultados = await Future.wait([
      _produtoRepository.buscarProdutosPorNome(termo).catchError((_) => <ProdutosModel>[]),
      if (categoriaParaBuscar != null)
        _produtoRepository.buscarPorCategoria(categoriaParaBuscar).catchError((_) => <ProdutosModel>[])
      else
        Future.value(<ProdutosModel>[]),
      _lojaRepository.buscarLojasPorNome(termo).catchError((_) => <LojasModel>[]),
    ]);

    final produtosPorNome = resultados[0] as List<ProdutosModel>;
    final produtosPorCategoria = resultados[1] as List<ProdutosModel>;
    final lojas = resultados[2] as List<LojasModel>;

    final produtosUnicos = <String, ProdutosModel>{};
    for (final p in [...produtosPorNome, ...produtosPorCategoria]) {
      produtosUnicos[p.id] = p;
    }

    final produtosFinais = produtosUnicos.values.toList();
    return _ResultadoBusca(
      produtos: produtosFinais,
      lojas: lojas,
      lojaAberta: await _statusDasLojas(produtosFinais),
    );
  }

  static final Map<String, String> _categoriasConhecidas = {
    for (final cat in _categoriasSugeridas)
      _normalizarTexto(cat['nome'] as String): cat['nome'] as String,
  };

  static String _normalizarTexto(String texto) {
    const comAcento = 'áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ';
    const semAcento = 'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC';
    var resultado = texto.trim().toLowerCase();
    for (var i = 0; i < comAcento.length; i++) {
      resultado = resultado.replaceAll(comAcento[i].toLowerCase(), semAcento[i].toLowerCase());
    }
    return resultado;
  }

  /// Retorna o nome exato da categoria (como o backend espera) se [termo]
  /// corresponder a alguma categoria conhecida, ignorando maiúsculas/acentos.
  String? _resolverCategoria(String termo) {
    return _categoriasConhecidas[_normalizarTexto(termo)];
  }

  void _limparBusca() {
    setState(() {
      _searchController.clear();
      _searchFuture = null;
      _filtro = _FiltroBusca.tudo;
    });
  }

  void _abrirProduto(ProdutosModel produto) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ProdutoDetalhesPage(produto: produto),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _abrirLoja(LojasModel loja) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => LojaPage(loja: loja),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _corSuperficie,
      body: SafeArea(
        child: Column(
          children: [
            _buildBarraBusca(),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: _searchFuture != null ? _buildFiltros() : const SizedBox(width: double.infinity),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.03),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: _searchFuture == null
                    ? _buildEstadoInicial()
                    : FutureBuilder<_ResultadoBusca>(
                        key: ValueKey(_searchFuture),
                        future: _searchFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              key: ValueKey('loading'),
                              child: LoadingNhac(telaCheia: false, tamanho: 110),
                            );
                          }
                          if (snapshot.hasError) {
                            return _buildMensagemEstado(
                              key: const ValueKey('erro'),
                              icone: Icons.error_outline_rounded,
                              titulo: 'Ops, algo deu errado',
                              subtitulo: 'Não foi possível concluir a busca. Tente novamente.',
                            );
                          }
                          if (!snapshot.hasData || snapshot.data!.vazio) {
                            return _buildMensagemEstado(
                              key: const ValueKey('vazio'),
                              icone: Icons.search_off_rounded,
                              titulo: 'Nada encontrado',
                              subtitulo: 'Tente pesquisar com outras palavras.',
                            );
                          }

                          return KeyedSubtree(
                            key: const ValueKey('resultados'),
                            child: _buildResultados(snapshot.data!),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarraBusca() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(Icons.arrow_back_ios_new_rounded, color: _corTexto, size: 18.r),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Container(
              height: 46.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50.r),
                border: Border.all(
                  color: _searchFocus.hasFocus ? _corPrimaria : Colors.transparent,
                  width: 1.5,
                ),
                boxShadow: _searchFocus.hasFocus
                    ? []
                    : [
                        BoxShadow(
                          color: _corTexto.withValues(alpha: 0.05),
                          blurRadius: 10.r,
                          offset: Offset(0, 4.h),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: _corTexto.withValues(alpha: 0.6), size: 20.r),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      onSubmitted: _iniciarBusca,
                      style: TextStyle(color: _corTexto, fontSize: 14.sp, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: 'Pesquisar produtos ou lojas...',
                        hintStyle: TextStyle(
                          color: _corTexto.withValues(alpha: 0.4),
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: _temTexto
                        ? GestureDetector(
                            key: const ValueKey('clear'),
                            onTap: _limparBusca,
                            child: Icon(Icons.close_rounded,
                                color: _corTexto.withValues(alpha: 0.5), size: 18.r),
                          )
                        : const SizedBox.shrink(key: ValueKey('empty')),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          _chipFiltro('Tudo', _FiltroBusca.tudo),
          SizedBox(width: 8.w),
          _chipFiltro('Produtos', _FiltroBusca.produtos),
          SizedBox(width: 8.w),
          _chipFiltro('Lojas', _FiltroBusca.lojas),
        ],
      ),
    );
  }

  Widget _chipFiltro(String label, _FiltroBusca valor) {
    final selecionado = _filtro == valor;
    return GestureDetector(
      onTap: () => setState(() => _filtro = valor),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selecionado ? _corPrimaria : Colors.white,
          borderRadius: BorderRadius.circular(50.r),
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            color: selecionado ? Colors.white : _corTexto,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
          child: Text(label),
        ),
      ),
    );
  }

  Widget _buildEstadoInicial() {
    return ListView(
      key: const ValueKey('inicial'),
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      children: [
        if (_historico.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pesquisas recentes',
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: _corTexto)),
              GestureDetector(
                onTap: () async {
                  setState(() => _historico = []);
                  await LocalCacheService.salvarHistoricoPesquisa([]);
                },
                child: Text('Limpar',
                    style: TextStyle(
                        fontSize: 13.sp, color: _corPrimaria, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: List.generate(_historico.length, (i) {
              final termo = _historico[i];
              return _StaggeredFadeIn(
                index: i,
                child: GestureDetector(
                  onTap: () => _iniciarBusca(termo),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50.r),
                      boxShadow: [
                        BoxShadow(
                          color: _corTexto.withValues(alpha: 0.04),
                          blurRadius: 6.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history_rounded, size: 15.r, color: _corTexto.withValues(alpha: 0.5)),
                        SizedBox(width: 6.w),
                        Text(termo, style: TextStyle(fontSize: 13.sp, color: _corTexto)),
                        SizedBox(width: 6.w),
                        GestureDetector(
                          onTap: () => _removerDoHistorico(termo),
                          child: Icon(Icons.close_rounded,
                              size: 14.r, color: _corTexto.withValues(alpha: 0.4)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 28.h),
        ],
        Text('Categorias',
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: _corTexto)),
        SizedBox(height: 12.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 2.6,
          ),
          itemCount: _categoriasSugeridas.length,
          itemBuilder: (context, i) {
            final cat = _categoriasSugeridas[i];
            return _StaggeredFadeIn(
              index: i,
              child: GestureDetector(
                onTap: () => _buscarPorCategoriaInicial(cat['nome'] as String),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: _corTexto.withValues(alpha: 0.05),
                        blurRadius: 10.r,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34.w,
                        height: 34.w,
                        decoration: const BoxDecoration(color: _corAccentClaro, shape: BoxShape.circle),
                        child: Icon(cat['icon'] as IconData, color: _corPrimaria, size: 18.r),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          cat['nome'] as String,
                          style: TextStyle(
                              fontSize: 13.sp, fontWeight: FontWeight.w600, color: _corTexto),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMensagemEstado({
    required Key key,
    required IconData icone,
    required String titulo,
    required String subtitulo,
  }) {
    return Center(
      key: key,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: const BoxDecoration(color: _corAccentClaro, shape: BoxShape.circle),
              child: Icon(icone, color: _corPrimaria, size: 34.r),
            ),
            SizedBox(height: 16.h),
            Text(titulo,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: _corTexto)),
            SizedBox(height: 6.h),
            Text(
              subtitulo,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: _corTexto.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultados(_ResultadoBusca resultado) {
    final mostrarLojas = _filtro != _FiltroBusca.produtos && resultado.lojas.isNotEmpty;
    final mostrarProdutos = _filtro != _FiltroBusca.lojas && resultado.produtos.isNotEmpty;

    if (!mostrarLojas && !mostrarProdutos) {
      return _buildMensagemEstado(
        key: const ValueKey('filtro-vazio'),
        icone: Icons.search_off_rounded,
        titulo: _filtro == _FiltroBusca.lojas ? 'Nenhuma loja encontrada' : 'Nenhum produto encontrado',
        subtitulo: 'Tente outro filtro ou outra palavra-chave.',
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
      children: [
        if (mostrarLojas) ...[
          Text('Lojas', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: _corTexto)),
          SizedBox(height: 10.h),
          ...List.generate(resultado.lojas.length, (i) {
            return _StaggeredFadeIn(
              index: i,
              child: _buildLojaTile(resultado.lojas[i]),
            );
          }),
          SizedBox(height: 20.h),
        ],
        if (mostrarProdutos) ...[
          Text('Produtos',
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: _corTexto)),
          SizedBox(height: 10.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 0.70,
            ),
            itemCount: resultado.produtos.length,
            itemBuilder: (context, index) {
              final produto = resultado.produtos[index];
              return _StaggeredFadeIn(
                index: index,
                child: GestureDetector(
                  onTap: () => _abrirProduto(produto),
                  child: ProductCard(
                    produto: produto,
                    lojaFechada: resultado.lojaAberta[produto.lojaId] != true,
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildLojaTile(LojasModel loja) {
    return GestureDetector(
      onTap: () => _abrirLoja(loja),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: _corTexto.withValues(alpha: 0.05),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: CachedNetworkImage(
                imageUrl: loja.imagemUrl,
                width: 52.w,
                height: 52.w,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(width: 52.w, height: 52.w, color: Colors.white),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 52.w,
                  height: 52.w,
                  color: _corAccentClaro,
                  child: Icon(Icons.storefront_rounded, color: _corPrimaria, size: 24.r),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loja.nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: _corTexto),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Container(
                        width: 7.w,
                        height: 7.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: loja.isAberto ? const Color(0xFF4CAF50) : Colors.grey.shade400,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        loja.isAberto ? loja.categoria : 'Fechada no momento',
                        style: TextStyle(fontSize: 12.sp, color: _corTexto.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: _corTexto.withValues(alpha: 0.3), size: 22.r),
          ],
        ),
      ),
    );
  }
}

/// Faz um item de lista/grid entrar com fade + leve deslize de baixo pra cima,
/// escalonado pelo índice — dá uma sensação de "resultados chegando" sem
/// depender de nenhum pacote de animação externo.
class _StaggeredFadeIn extends StatefulWidget {
  final Widget child;
  final int index;

  const _StaggeredFadeIn({required this.child, required this.index});

  @override
  State<_StaggeredFadeIn> createState() => _StaggeredFadeInState();
}

class _StaggeredFadeInState extends State<_StaggeredFadeIn> {
  bool _visivel = false;

  @override
  void initState() {
    super.initState();
    final delay = Duration(milliseconds: 30 * (widget.index % 12));
    Future.delayed(delay, () {
      if (mounted) setState(() => _visivel = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visivel ? 1 : 0,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _visivel ? Offset.zero : const Offset(0, 0.08),
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
