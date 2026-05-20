import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nhac/models/produto/produtos.dart';
import 'package:nhac/pages/produto_detalhes_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nhac/components/product_card.dart';

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

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
        _hasSubmitted = false;
      });
    });
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedItem(Widget child, int index) {
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          (index * 0.1).clamp(0.0, 1.0),
          (index * 0.1 + 0.5).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - animation.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 24.0, right: 24.0, bottom: 24.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF5D201C).withValues(alpha: 0.05),
                            blurRadius: 10.0,
                            offset: const Offset(0.0, 4.0),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF5D201C),
                        size: 20.0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Hero(
                      tag: 'search_bar',
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50.0),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF5D201C).withValues(alpha: 0.05),
                                blurRadius: 10.0,
                                offset: const Offset(0.0, 4.0),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: Colors.grey),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  autofocus: true,
                                  textInputAction: TextInputAction.search,
                                  onSubmitted: (value) {
                                    setState(() {
                                      _hasSubmitted = true;
                                    });
                                    _animationController.forward(from: 0.0);
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Procurar',
                                    hintStyle: TextStyle(color: Colors.grey.shade400),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      children: [
                        _buildAnimatedItem(
                          const Text(
                            'Sugestões',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5D201C),
                            ),
                          ),
                          0,
                        ),
                        const SizedBox(height: 16.0),
                        _buildAnimatedItem(_buildSuggestionItem(Icons.history, 'Pãozinho'), 1),
                        _buildAnimatedItem(_buildSuggestionItem(Icons.history, 'Coxinha'), 2),
                        const SizedBox(height: 24.0),
                        _buildAnimatedItem(
                          const Text(
                            'Em alta',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5D201C),
                            ),
                          ),
                          3,
                        ),
                        const SizedBox(height: 16.0),
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
      leading: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: isTrending ? const Color(0xFFFF6961).withValues(alpha: 0.1) : Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isTrending ? const Color(0xFFFF6961) : Colors.grey,
          size: 20.0,
        ),
      ),
      title: Text(
        text,
        style: TextStyle(
          color: isTrending ? const Color(0xFF5D201C) : Colors.black87,
          fontWeight: isTrending ? FontWeight.w600 : FontWeight.normal,
          fontSize: 15.0,
        ),
      ),
      trailing: const Icon(Icons.north_west, color: Colors.grey, size: 16.0),
      contentPadding: const EdgeInsets.only(bottom: 8.0),
      onTap: () {
        _searchController.text = text;
      },
    );
  }

  Widget _buildSearchResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('produtos').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6961)),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Nenhum produto encontrado.', style: TextStyle(color: Colors.grey)));
        }

        final produtos = snapshot.data!.docs.map((doc) {
          return ProdutosModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).where((p) => p.nome.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

        if (produtos.isEmpty) {
          return const Center(child: Text('Nenhum produto encontrado para sua pesquisa.', style: TextStyle(color: Colors.grey)));
        }

        if (_hasSubmitted) {
          return GridView.builder(
            padding: const EdgeInsets.all(24.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
              childAspectRatio: 0.7,
            ),
            itemCount: produtos.length,
            itemBuilder: (context, index) {
              final produto = produtos[index];
              return _buildAnimatedItem(
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProdutoDetalhesPage(produto: produto),
                      ),
                    );
                  },
                  child: ProductCard(
                    idProduto: produto.uid,
                    imageUrl: produto.imagemUrl.isNotEmpty ? produto.imagemUrl : 'https://via.placeholder.com/150',
                    name: produto.nome,
                    weight: '1 un',
                    price: produto.preco,
                  ),
                ),
                index,
              );
            },
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          itemCount: produtos.length,
          itemBuilder: (context, index) {
            final produto = produtos[index];
            return _buildAnimatedItem(
              ListTile(
                contentPadding: const EdgeInsets.only(bottom: 8.0),
                leading: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.search,
                    color: Colors.grey,
                    size: 20.0,
                  ),
                ),
                title: Text(
                  produto.nome,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.normal,
                    fontSize: 15.0,
                  ),
                ),
                trailing: const Icon(Icons.north_west, color: Colors.grey, size: 16.0),
                onTap: () {
                  _searchController.text = produto.nome;
                  setState(() {
                    _hasSubmitted = true;
                  });
                  _animationController.forward(from: 0.0);
                },
              ),
              index,
            );
          },
        );
      },
    );
  }
}
