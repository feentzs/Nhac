import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/loja/lojas.dart';
import '../models/produto/produtos.dart';
import '../components/product_card.dart';
import '../components/seta_voltar.dart';
import '../pages/produto_detalhes_page.dart';

class LojaPage extends StatelessWidget {
  final LojasModel loja;
  const LojaPage({super.key, required this.loja});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE7E5),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.h,
            pinned: true,
            backgroundColor: const Color(0xFFFFE7E5),
            leading: const Padding(padding: EdgeInsets.all(8.0), child: SetaVoltar()),
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: loja.imagemUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey.shade100, child: Center(child: CircularProgressIndicator(color: const Color(0xFFFF6961)))),
                errorWidget: (context, url, error) => Container(color: Colors.grey.shade300, child: Icon(Icons.store, size: 80.sp, color: Colors.grey)),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: const BoxDecoration(color: Color(0xFFFFE7E5), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loja.nome, style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold, color: const Color(0xFF5D201C))),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      SizedBox(width: 4.w),
                      Text('${loja.mediaAvaliacao.toStringAsFixed(1)} (${loja.totalAvaliacoes} avaliações)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                      SizedBox(width: 16.w),
                      Text('•  ${loja.categoria}', style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                  SizedBox(height: 32.h),
                  Text('Cardápio', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: const Color(0xFF5D201C))),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('produtos').where('loja_id', isEqualTo: loja.uid).where('disponivel', isEqualTo: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return Center(child: Padding(padding: EdgeInsets.all(32.w), child: CircularProgressIndicator(color: const Color(0xFFFF6961))));
                  if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) return Center(child: Padding(padding: EdgeInsets.all(32.w), child: Text('Nenhum produto disponível no momento 😥', style: TextStyle(color: Colors.grey.shade600))));
                  final produtos = snapshot.data!.docs.map((doc) => ProdutosModel.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16.w, mainAxisSpacing: 16.h, childAspectRatio: 0.75),
                    itemCount: produtos.length,
                    itemBuilder: (context, index) {
                      final produto = produtos[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProdutoDetalhesPage(produto: produto))),
                        child: ProductCard(idProduto: produto.uid, imageUrl: produto.imagemUrl.isNotEmpty ? produto.imagemUrl : 'https://via.placeholder.com/150', name: produto.nome, weight: '', price: produto.preco),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 100.h)),
        ],
      ),
    );
  }
}