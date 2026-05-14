import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:nhac/components/home_product_section.dart';
import 'package:nhac/models/produto/produtos.dart';

class ProdutoDetalhesPage extends StatelessWidget {
  final ProdutosModel produto;

  const ProdutoDetalhesPage({super.key, required this.produto});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height * 0.45,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.share_outlined, color: Colors.black, size: 20),
                        onPressed: () {
                          final link = 'https://nhac.app/produto/${produto.uid}';
                          Share.share(
                            'Confira este produto no Nhac!\n\n'
                            '${produto.nome}\n'
                            'Por R\$ ${produto.preco.toStringAsFixed(2).replaceAll('.', ',')}\n\n'
                            '$link',
                            subject: produto.nome,
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.more_horiz, color: Colors.black, size: 20),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'produto_${produto.uid}',
                    child: produto.imagemUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: produto.imagemUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: const Color(0xFFF5F5F5),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6961)),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: const Color(0xFFF5F5F5),
                              child: const Icon(Icons.fastfood, size: 80, color: Colors.grey),
                            ),
                          )
                        : Container(
                            color: const Color(0xFFF5F5F5),
                            child: const Icon(Icons.fastfood, size: 80, color: Colors.grey),
                          ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                        child: Text(
                          produto.nome,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              currencyFormat.format(produto.preco),
                              style: const TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFF6961),
                                letterSpacing: -1.5,
                                shadows: [
                                  Shadow(offset: Offset(-0.8, -0.8), color: Color(0xFFFF6961)),
                                  Shadow(offset: Offset(0.8, -0.8), color: Color(0xFFFF6961)),
                                  Shadow(offset: Offset(0.8, 0.8), color: Color(0xFFFF6961)),
                                  Shadow(offset: Offset(-0.8, 0.8), color: Color(0xFFFF6961)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (produto.totalAvaliacoes > 0)
                              Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF5E5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      produto.mediaAvaliacao.toStringAsFixed(1),
                                      style: const TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F9F9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              _buildServiceRow(Icons.bolt, 'Envio imediato após a compra'),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                              ),
                              _buildServiceRow(Icons.check_circle_outline, 'Garantia de reembolso em caso de problemas'),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                              ),
                              FutureBuilder<DocumentSnapshot?>(
                                future: produto.lojaId.isNotEmpty
                                    ? FirebaseFirestore.instance.collection('lojas').doc(produto.lojaId).get()
                                    : Future.value(null),
                                builder: (context, snapshot) {
                                  String nomeLoja = 'Loja Parceira';
                                  if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data!.exists) {
                                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                                    if (data != null && data['nome'] != null) {
                                      nomeLoja = data['nome'];
                                    }
                                  }
                                  return _buildServiceRow(Icons.storefront_outlined, 'Vendido por: $nomeLoja');
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Detalhes do Produto',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          produto.descricao.isNotEmpty 
                              ? produto.descricao 
                              : 'Este produto é preparado com ingredientes frescos e selecionados. Perfeito para qualquer momento do dia.',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                            height: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('produtos')
                              .limit(5)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            final produtosRelacionados = snapshot.data!.docs
                                .map((doc) => ProdutosModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
                                .where((p) => p.uid != produto.uid)
                                .map((prod) => ProductSectionItem(
                                      idProduto: prod.uid,
                                      imageUrl: prod.imagemUrl.isNotEmpty ? prod.imagemUrl : 'https://via.placeholder.com/150',
                                      name: prod.nome,
                                      weight: '',
                                      price: prod.preco,
                                      discountPercent: null,
                                    ))
                                .toList();

                            if (produtosRelacionados.isEmpty) return const SizedBox.shrink();

                            return HomeProductSection(
                              title: 'Produtos Relacionados',
                              products: produtosRelacionados,
                              onSeeAll: () {},
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 100 + bottomPadding),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: bottomPadding > 0 ? bottomPadding : 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildIconAction(Icons.star_border, 'Favoritar', '118'),
                  const SizedBox(width: 16),
                  _buildIconAction(Icons.chat_bubble_outline, 'Chat', ''),
                  const SizedBox(width: 24),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6961),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Text(
                        'Comprar  ${currencyFormat.format(produto.preco)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF888888)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF555555),
            ),
          ),
        ),
        const Icon(Icons.chevron_right, size: 20, color: Color(0xFFCCCCCC)),
      ],
    );
  }

  Widget _buildIconAction(IconData icon, String label, String count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: const Color(0xFF666666)),
        const SizedBox(height: 4),
        Text(
          count.isNotEmpty ? count : label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF888888),
          ),
        ),
      ],
    );
  }
}
