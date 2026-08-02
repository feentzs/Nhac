import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/produto/produtos.dart';
import '../models/loja/lojas.dart';
import '../components/product_card.dart';
import '../repositories/produto_repository.dart';
import '../repositories/loja_repository.dart';
import 'produto_detalhes_page.dart';
import 'loja_page.dart';

enum _FiltroBusca { tudo, produtos, lojas }

class _ResultadoBusca {
  final List<ProdutosModel> produtos;
  final List<LojasModel> lojas;
  _ResultadoBusca({required this.produtos, required this.lojas});

  bool get vazio => produtos.isEmpty && lojas.isEmpty;
}

class SearchPage extends StatefulWidget {
  final String? initialCategory;

  const SearchPage({super.key, this.initialCategory});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ProdutoRepository _produtoRepository = ProdutoRepository();
  final LojaRepository _lojaRepository = LojaRepository();

  Future<_ResultadoBusca>? _searchFuture;
  _FiltroBusca _filtro = _FiltroBusca.tudo;

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null && widget.initialCategory!.isNotEmpty) {
      _searchController.text = widget.initialCategory!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _buscarPorCategoriaInicial(widget.initialCategory!);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _buscarPorCategoriaInicial(String categoria) {
    if (categoria.isEmpty) return;
    setState(() {
      _searchFuture = _produtoRepository
          .buscarPorCategoria(categoria)
          .then((produtos) => _ResultadoBusca(produtos: produtos, lojas: const []));
    });
  }

  /// Busca unificada: produtos por NOME + produtos por CATEGORIA (mesclados,
  /// sem duplicar) + lojas por NOME — tudo a partir do mesmo termo digitado.
  void _iniciarBusca(String termo) {
    if (termo.isEmpty) return;
    setState(() {
      _searchFuture = _buscarTudo(termo);
    });
  }

  Future<_ResultadoBusca> _buscarTudo(String termo) async {
    final resultados = await Future.wait([
      _produtoRepository.buscarProdutosPorNome(termo),
      _produtoRepository.buscarPorCategoria(termo),
      _lojaRepository.buscarLojasPorNome(termo),
    ]);

    final produtosPorNome = resultados[0] as List<ProdutosModel>;
    final produtosPorCategoria = resultados[1] as List<ProdutosModel>;
    final lojas = resultados[2] as List<LojasModel>;

    final produtosUnicos = <String, ProdutosModel>{};
    for (final p in [...produtosPorNome, ...produtosPorCategoria]) {
      produtosUnicos[p.id] = p;
    }

    return _ResultadoBusca(produtos: produtosUnicos.values.toList(), lojas: lojas);
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
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Pesquisar produtos ou lojas..."),
          onSubmitted: _iniciarBusca,
        ),
      ),
      body: Column(
        children: [
          if (_searchFuture != null) _buildFiltros(),
          Expanded(
            child: _searchFuture == null
                ? const Center(child: Text("Digite algo para pesquisar"))
                : FutureBuilder<_ResultadoBusca>(
                    future: _searchFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'Erro ao buscar: ${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.vazio) {
                        return const Center(child: Text("Nada encontrado."));
                      }

                      final resultado = snapshot.data!;
                      return _buildResultados(resultado);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
    return ChoiceChip(
      label: Text(label),
      selected: selecionado,
      onSelected: (_) => setState(() => _filtro = valor),
    );
  }

  Widget _buildResultados(_ResultadoBusca resultado) {
    final mostrarLojas = _filtro != _FiltroBusca.produtos && resultado.lojas.isNotEmpty;
    final mostrarProdutos = _filtro != _FiltroBusca.lojas && resultado.produtos.isNotEmpty;

    if (!mostrarLojas && !mostrarProdutos) {
      return Center(
        child: Text(_filtro == _FiltroBusca.lojas
            ? 'Nenhuma loja encontrada.'
            : 'Nenhum produto encontrado.'),
      );
    }

    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        if (mostrarLojas) ...[
          Text('Lojas', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          ...resultado.lojas.map((loja) => _buildLojaTile(loja)),
          SizedBox(height: 16.h),
        ],
        if (mostrarProdutos) ...[
          Text('Produtos', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
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
              return GestureDetector(
                onTap: () => _abrirProduto(produto),
                child: ProductCard(produto: produto),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildLojaTile(LojasModel loja) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: CachedNetworkImage(
            imageUrl: loja.imagemUrl,
            width: 48.w,
            height: 48.w,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => Container(
              width: 48.w,
              height: 48.w,
              color: Colors.grey.shade200,
              child: const Icon(Icons.storefront_outlined),
            ),
          ),
        ),
        title: Text(loja.nome),
        subtitle: Text(loja.isAberto ? loja.categoria : 'Fechada no momento'),
        onTap: () => _abrirLoja(loja),
      ),
    );
  }
}
