import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/loja/lojas.dart';
import '../models/produto/produtos.dart';
import '../components/product_card.dart'; 
import '../components/seta_voltar.dart'; 

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
            expandedHeight: 200.0,
            pinned: true,
            backgroundColor: const Color(0xFFFFE7E5),
            leading: const Padding(
              padding: EdgeInsets.all(8.0),
              child: SetaVoltar(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: loja.imagemUrl.isNotEmpty
                  ? Image.network(
                      loja.imagemUrl,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.store, size: 80, color: Colors.grey),
                    ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                color: Color(0xFFFFE7E5),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loja.nome,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D201C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${loja.mediaAvaliacao.toStringAsFixed(1)} (${loja.totalAvaliacoes} avaliações)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '•  ${loja.categoria}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Cardápio',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D201C),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // 👇 LISTA DE PRODUTOS DO FIREBASE 👇
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('produtos')
                    .where('loja_id', isEqualTo: loja.uid)
                    .where('disponivel', isEqualTo: true) 
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(color: Color(0xFFFF6961)),
                      ),
                    );
                  }

                  if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          'Nenhum produto disponível no momento 😥',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    );
                  }

                  final produtos = snapshot.data!.docs.map((doc) {
                    return ProdutosModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                  }).toList();

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(), 
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, 
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75, 
                    ),
                    itemCount: produtos.length,
                    itemBuilder: (context, index) {
                      final produto = produtos[index];

                      return ProductCard(
                        idProduto: produto.uid,
                        imageUrl: produto.imagemUrl.isNotEmpty 
                            ? produto.imagemUrl 
                            : 'https://via.placeholder.com/150', 
                        name: produto.nome,
                        weight: '', 
                        price: produto.preco,
                      );
                    },
                  );
                },
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)), 
        ],
      ),
    );
  }
}