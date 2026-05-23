import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nhac/models/produto/produtos.dart';
import 'package:nhac/pages/produto_detalhes_page.dart';
import 'package:nhac/components/product_card.dart';
import 'package:nhac/services/local_cache_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  String _searchQuery = '';
  bool _hasSubmitted = false;
  List<String> _historicoPesquisa = [];

  @override
  void initState() {
    super.initState();
    LocalCacheService.carregarHistoricoPesquisa().then((lista) { if (mounted) setState(() => _historicoPesquisa = lista); });
    _searchController.addListener(() { setState(() { _searchQuery = _searchController.text.trim(); _hasSubmitted = false; }); });
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _animationController.forward();
  }

  @override
  void dispose() { _animationController.dispose(); _searchController.dispose(); super.dispose(); }

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
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Interval((index * 0.1).clamp(0.0, 1.0), (index * 0.1 + 0.5).clamp(0.0, 1.0), curve: Curves.easeOutCubic)));
    return AnimatedBuilder(animation: animation, builder: (context, child) => Opacity(opacity: animation.value, child: Transform.translate(offset: Offset(0, 30 * (1 - animation.value)), child: child)), child: child);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 8.h, left: 24.w, right: 24.w, bottom: 24.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(padding: EdgeInsets.all(8.w), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFF5D201C).withValues(alpha: 0.05), blurRadius: 10.r, offset: Offset(0, 4.h))]), child: Icon(Icons.arrow_back, color: const Color(0xFF5D201C), size: 20.sp)),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Hero(
                      tag: 'search_bar',
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(50.r), boxShadow: [BoxShadow(color: const Color(0xFF5D201C).withValues(alpha: 0.05), blurRadius: 10.r, offset: Offset(0, 4.h))]),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: Colors.grey),
                              SizedBox(width: 8.w),
                              Expanded(child: TextField(controller: _searchController, autofocus: true, textInputAction: TextInputAction.search, onSubmitted: (value) { _salvarPesquisa(value); setState(() => _hasSubmitted = true); _animationController.forward(from: 0.0); }, decoration: InputDecoration(hintText: 'Procurar', hintStyle: TextStyle(color: Colors.grey.shade400), border: InputBorder.none))),
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
              child: _searchQuery.isEmpty
                  ? ListView(
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      children: [
                        if (_historicoPesquisa.isNotEmpty) ...[
                          _buildAnimatedItem(Text('Sugestões', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: const Color(0xFF5D201C))), 0),
                          SizedBox(height: 16.h),
                          ..._historicoPesquisa.asMap().entries.map((entry) => _buildAnimatedItem(_buildSuggestionItem(Icons.history, entry.value), entry.key + 1)),
                          SizedBox(height: 24.h),
                        ],
                        _buildAnimatedItem(Text('Em alta', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: const Color(0xFF5D201C))), 3),
                        SizedBox(height: 16.h),
                        _buildAnimatedItem(_buildSuggestionItem(Icons.trending_up, 'Refrigerante Viver', isTrending: true), 4),
                        _buildAnimatedItem(_buildSuggestionItem(Icons.trending_up, 'Carne', isTrending: true), 5),
                      ],
                    )
                  : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(IconData icon, String text, {bool isTrending = false}) {
    return ListTile(
      leading: Container(padding: EdgeInsets.all(8.w), decoration: BoxDecoration(color: isTrending ? const Color(0xFFFF6961).withValues(alpha: 0.1) : Colors.grey.shade100, shape: BoxShape.circle), child: Icon(icon, color: isTrending ? const Color(0xFFFF6961) : Colors.grey, size: 20.sp)),
      title: Text(text, style: TextStyle(color: isTrending ? const Color(0xFF5D201C) : Colors.black87, fontWeight: isTrending ? FontWeight.w600 : FontWeight.normal, fontSize: 15.sp)),
      trailing: Icon(Icons.north_west, color: Colors.grey, size: 16.sp),
      contentPadding: EdgeInsets.only(bottom: 8.h),
      onTap: () { _searchController.text = text; _salvarPesquisa(text); setState(() => _hasSubmitted = true); _animationController.forward(from: 0.0); },
    );
  }

  Widget _buildSearchResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('produtos').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF6961))));
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('Nenhum produto encontrado.', style: TextStyle(color: Colors.grey)));
        final produtos = snapshot.data!.docs.map((doc) => ProdutosModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).where((p) => p.nome.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
        if (produtos.isEmpty) return const Center(child: Text('Nenhum produto encontrado para sua pesquisa.', style: TextStyle(color: Colors.grey)));
        if (_hasSubmitted) {
          return GridView.builder(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: EdgeInsets.all(24.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 16.w, crossAxisSpacing: 16.w, childAspectRatio: 0.7),
            itemCount: produtos.length,
            itemBuilder: (context, index) => _buildAnimatedItem(
              GestureDetector(
                onTap: () => Navigator.push(context, PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => ProdutoDetalhesPage(produto: produtos[index]), transitionsBuilder: (context, animation, secondaryAnimation, child) { const begin = Offset(0.0, 1.0); const end = Offset.zero; const curve = Curves.easeOutCubic; var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve)); return SlideTransition(position: animation.drive(tween), child: child); }, transitionDuration: const Duration(milliseconds: 300))),
                child: ProductCard(idProduto: produtos[index].uid, imageUrl: produtos[index].imagemUrl.isNotEmpty ? produtos[index].imagemUrl : 'https://via.placeholder.com/150', name: produtos[index].nome, weight: '1 un', price: produtos[index].preco),
              ),
              index,
            ),
          );
        }
        return ListView.builder(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          itemCount: produtos.length,
          itemBuilder: (context, index) => _buildAnimatedItem(
            ListTile(
              contentPadding: EdgeInsets.only(bottom: 8.h),
              leading: Container(padding: EdgeInsets.all(8.w), decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle), child: Icon(Icons.search, color: Colors.grey, size: 20.sp)),
              title: Text(produtos[index].nome, style: TextStyle(color: Colors.black87, fontSize: 15.sp)),
              trailing: Icon(Icons.north_west, color: Colors.grey, size: 16.sp),
              onTap: () { _searchController.text = produtos[index].nome; _salvarPesquisa(produtos[index].nome); setState(() => _hasSubmitted = true); _animationController.forward(from: 0.0); },
            ),
            index,
          ),
        );
      },
    );
  }
}