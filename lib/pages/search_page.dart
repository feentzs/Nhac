import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/produto/produtos.dart';
import '../components/product_card.dart';
import '../repositories/produto_repository.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ProdutoRepository _repository = ProdutoRepository();
  
  Future<List<ProdutosModel>>? _searchFuture;

  void _iniciarBusca(String termo) {
    if (termo.isEmpty) return;
    setState(() {
      _searchFuture = _repository.buscarProdutosPorNome(termo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Pesquisar produtos..."),
          onSubmitted: _iniciarBusca,
        ),
      ),
      body: _searchFuture == null
          ? const Center(child: Text("Digite algo para pesquisar"))
          : FutureBuilder<List<ProdutosModel>>(
              future: _searchFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Nenhum produto encontrado."));
                }

                final produtos = snapshot.data!;
                return GridView.builder(
                  padding: EdgeInsets.all(16.w),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 0.70,
                  ),
                  itemCount: produtos.length,
                  itemBuilder: (context, index) {
                    return ProductCard(produto: produtos[index]);
                  },
                );
              },
            ),
    );
  }
}