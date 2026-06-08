import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nhac/models/produto/produtos.dart';
import 'package:nhac/pages/produto_detalhes_page.dart';
import 'package:nhac/components/product_card.dart';
import 'package:nhac/services/local_cache_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, this.initialCategory});

  final String? initialCategory;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  String _searchQuery = '';
  bool _hasSubmitted = false;
  List<String> _historicoPesquisa = [];
  Future<List<ProdutosModel>>? _searchFuture;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));

    if (widget.initialCategory != null) {
      _searchController.text = widget.initialCategory!;
      _searchQuery = widget.initialCategory!;
      _executarBusca(_searchQuery);
    }

    LocalCacheService.carregarHistoricoPesquisa().then((lista) {
      if (mounted) setState(() => _historicoPesquisa = lista);
    });

    _animationController.forward();
  }

  @override
  void didUpdateWidget(covariant SearchPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategory != oldWidget.initialCategory &&
        widget.initialCategory != null) {
      _searchController.text = widget.initialCategory!;
      _searchQuery = widget.initialCategory!;
      _executarBusca(_searchQuery);
    }
  }

  void _executarBusca(String termo) {
    if (termo.trim().isEmpty) return;

    _salvarPesquisa(termo);
    setState(() {
      _hasSubmitted = true;
      _searchQuery = termo;
      _searchFuture = _realizarBuscaLocal(termo);
    });
    _animationController.forward(from: 0.0);
  }

  Future<List<ProdutosModel>> _realizarBuscaLocal(String termo) async {

    
    Query query = FirebaseFirestore.instance
        .collection('produtos')
        .where('loja_is_aberto', isEqualTo: true);

    
    if (widget.initialCategory != null) {
      query = query.where('categoria_menu', isEqualTo: widget.initialCategory);
    }

    final snapshot = await query.get();

    final todosProdutos = snapshot.docs
        .map((doc) => ProdutosModel.fromMap(
            doc.data() as Map<String, dynamic>, doc.id))
        .toList();
      return todosProdutos.where((p) {
      if (widget.initialCategory != null && termo == widget.initialCategory) {
        return true; 
      }
      return p.nome.toLowerCase().contains(termo.toLowerCase());
    }).toList();
  }

  void _limparBusca() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _hasSubmitted = false;
      _searchFuture = null;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _salvarPesquisa(String termo) {
    if (termo.trim().isEmpty) return;
    setState(() {
      _historicoPesquisa.remove(termo);
      _historicoPesquisa.insert(0, termo);
      if (_historicoPesquisa.length > 5) _historicoPesquisa.removeLast();
    });
    LocalCacheService.salvarHistoricoPesquisa(_historicoPesquisa);
  }

  Widget _buildAnimatedItem(Widget child, int index) {
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _animationController,
            curve: Interval((index * 0.1).clamp(0.0, 1.0),
                (index * 0.1 + 0.5).clamp(0.0, 1.0),
                curve: Curves.easeOutCubic)));
    return AnimatedBuilder(
        animation: animation,
        builder: (context, child) => Opacity(
            opacity: animation.value,
            child: Transform.translate(
                offset: Offset(0, 30 * (1 - animation.value)), child: child)),
        child: child);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  top: 8.h, left: 24.w, right: 24.w, bottom: 24.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: const Color(0xFF5D201C)
                                      .withValues(alpha: 0.05),
                                  blurRadius: 10.r,
                                  offset: Offset(0, 4.h))
                            ]),
                        child: Icon(Icons.arrow_back,
                            color: const Color(0xFF5D201C), size: 20.sp)),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Hero(
                      tag: 'search_bar',
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 4.h),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50.r),
                              boxShadow: [
                                BoxShadow(
                                    color: const Color(0xFF5D201C)
                                        .withValues(alpha: 0.05),
                                    blurRadius: 10.r,
                                    offset: Offset(0, 4.h))
                              ]),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: Colors.grey),
                              SizedBox(width: 8.w),
                              Expanded(
                                  child: TextField(
                                      controller: _searchController,
                                      autofocus: true,
                                      textInputAction: TextInputAction.search,
                                      onSubmitted: _executarBusca,
                                      onChanged: (value) {
                                        if (value.isEmpty && _hasSubmitted) {
                                          _limparBusca();
                                        }
                                      },
                                      decoration: InputDecoration(
                                          hintText: 'Procurar',
                                          hintStyle: TextStyle(
                                              color: Colors.grey.shade400),
                                          border: InputBorder.none))),
                              if (_searchController.text.isNotEmpty)
                                GestureDetector(
                                  onTap: _limparBusca,
                                  child: const Icon(Icons.close, color: Colors.grey),
                                )
                              else
                                const Icon(Icons.tune, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: !_hasSubmitted || _searchQuery.isEmpty
                  ? ListView(
                      physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      children: [
                        if (_historicoPesquisa.isNotEmpty) ...[
                          _buildAnimatedItem(
                              Text('Sugestões',
                                  style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF5D201C))),
                              0),
                          SizedBox(height: 16.h),
                          ..._historicoPesquisa.asMap().entries.map((entry) =>
                              _buildAnimatedItem(
                                  _buildSuggestionItem(
                                      Icons.history, entry.value),
                                  entry.key + 1)),
                          SizedBox(height: 24.h),
                        ],
                        _buildAnimatedItem(
                            Text('Em alta',
                                style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF5D201C))),
                            3),
                        SizedBox(height: 16.h),
                        _buildAnimatedItem(
                            _buildSuggestionItem(
                                Icons.trending_up, 'Refrigerante Viver',
                                isTrending: true),
                            4),
                        _buildAnimatedItem(
                            _buildSuggestionItem(Icons.trending_up, 'Carne',
                                isTrending: true),
                            5),
                      ],
                    )
                  : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(IconData icon, String text,
      {bool isTrending = false}) {
    return ListTile(
      leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
              color: isTrending
                  ? const Color(0xFFFF6961).withValues(alpha: 0.1)
                  : Colors.grey.shade100,
              shape: BoxShape.circle),
          child: Icon(icon,
              color: isTrending ? const Color(0xFFFF6961) : Colors.grey,
              size: 20.sp)),
      title: Text(text,
          style: TextStyle(
              color: isTrending ? const Color(0xFF5D201C) : Colors.black87,
              fontWeight: isTrending ? FontWeight.w600 : FontWeight.normal,
              fontSize: 15.sp)),
      trailing: Icon(Icons.north_west, color: Colors.grey, size: 16.sp),
      contentPadding: EdgeInsets.only(bottom: 8.h),
      onTap: () {
        _searchController.text = text;
        _executarBusca(text);
      },
    );
  }

  Widget _buildSearchResults() {
    if (!_hasSubmitted || _searchFuture == null) return const SizedBox.shrink();

    return FutureBuilder<List<ProdutosModel>>(
      future: _searchFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFFFF6961))));
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: const Color(0xFFFF6961), size: 48.r),
                  SizedBox(height: 16.h),
                  Text(
                    'Ocorreu um erro ao buscar produtos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16.sp),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => _executarBusca(_searchQuery),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6961),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.r)),
                    ),
                    child: const Text('Tentar novamente', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          );
        }

        final produtos = snapshot.data ?? [];

        if (produtos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, color: Colors.grey, size: 64.r),
                SizedBox(height: 16.h),
                Text(
                  'Nenhum produto encontrado para "$_searchQuery".',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16.sp),
                ),
                SizedBox(height: 24.h),
                TextButton(
                  onPressed: _limparBusca,
                  child: const Text('Limpar busca', style: TextStyle(color: Color(0xFFFF6961), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          padding: EdgeInsets.all(24.w),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16.w,
              crossAxisSpacing: 16.w,
              childAspectRatio: 0.7),
          itemCount: produtos.length,
          itemBuilder: (context, index) => _buildAnimatedItem(
            GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          ProdutoDetalhesPage(produto: produtos[index]),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(0.0, 1.0);
                        const end = Offset.zero;
                        const curve = Curves.easeOutCubic;
                        var tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));
                        return SlideTransition(
                            position: animation.drive(tween), child: child);
                      },
                      transitionDuration: const Duration(milliseconds: 300))),
              child: ProductCard(
                  idProduto: produtos[index].uid,
                  imageUrl: produtos[index].imagemUrl.isNotEmpty
                      ? produtos[index].imagemUrl
                      : 'https://via.placeholder.com/150',
                  name: produtos[index].nome,
                  weight: '1 un',
                  price: produtos[index].preco),
            ),
            index,
          ),
        );
      },
    );
  }
}
