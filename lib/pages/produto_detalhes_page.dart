import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:nhac/components/home/home_product_section.dart';
import 'package:nhac/models/produto/produtos.dart';
import 'package:nhac/models/loja/lojas.dart';
import 'package:nhac/pages/loja_page.dart';
import 'package:shimmer/shimmer.dart';

class ProdutoDetalhesPage extends StatelessWidget {
  final ProdutosModel produto;

  const ProdutoDetalhesPage({super.key, required this.produto});

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
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
                  padding: EdgeInsets.all(8.w),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new,
                          color: Colors.black, size: 20.sp),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: EdgeInsets.all(8.w),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.share_outlined,
                            color: Colors.black, size: 20.sp),
                        onPressed: () {
                          final link =
                              'https://nhac.app/produto/${produto.uid}';
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
                    padding: EdgeInsets.all(8.w),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.more_horiz,
                            color: Colors.black, size: 20.sp),
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFFFF6961)),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: const Color(0xFFF5F5F5),
                              child: Icon(Icons.fastfood,
                                  size: 80.sp, color: Colors.grey),
                            ),
                          )
                        : Container(
                            color: const Color(0xFFF5F5F5),
                            child: Icon(Icons.fastfood,
                                size: 80.sp, color: Colors.grey),
                          ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24.r),
                      topRight: Radius.circular(24.r),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 10.h),
                        child: Text(
                          produto.nome,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              currencyFormat.format(produto.preco),
                              style: TextStyle(
                                fontSize: 42.sp,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFFFF6961),
                                letterSpacing: -1.5.sp,
                                shadows: [
                                  Shadow(
                                      offset: Offset(-0.8.w, -0.8.h),
                                      color: const Color(0xFFFF6961)),
                                  Shadow(
                                      offset: Offset(0.8.w, -0.8.h),
                                      color: const Color(0xFFFF6961)),
                                  Shadow(
                                      offset: Offset(0.8.w, 0.8.h),
                                      color: const Color(0xFFFF6961)),
                                  Shadow(
                                      offset: Offset(-0.8.w, 0.8.h),
                                      color: const Color(0xFFFF6961)),
                                ],
                              ),
                            ),
                            SizedBox(width: 8.w),
                            if (produto.totalAvaliacoes > 0)
                              Container(
                                margin: EdgeInsets.only(bottom: 6.h),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF5E5),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.star,
                                        color: Colors.amber, size: 14.sp),
                                    SizedBox(width: 4.w),
                                    Text(
                                      produto.mediaAvaliacao.toStringAsFixed(1),
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),
                      if (produto.lojaId.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('lojas')
                                .doc(produto.lojaId)
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return _buildLojaCardSkeleton();
                              }
                              if (!snapshot.hasData || !snapshot.data!.exists) {
                                return const SizedBox.shrink();
                              }

                              final loja = LojasModel.fromMap(
                                snapshot.data!.data() as Map<String, dynamic>,
                                snapshot.data!.id,
                              );

                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            LojaPage(loja: loja)),
                                  );
                                },
                                borderRadius: BorderRadius.circular(16.r),
                                child: Container(
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16.r),
                                    border: Border.all(
                                        color: const Color(0xFFEEEEEE),
                                        width: 1.w),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.02),
                                        blurRadius: 8.r,
                                        offset: Offset(0, 4.h),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                        child: CachedNetworkImage(
                                          imageUrl: loja.imagemUrl,
                                          width: 50.w,
                                          height: 50.w,
                                          fit: BoxFit.cover,
                                          errorWidget: (c, u, e) => Container(
                                            color: const Color(0xFFFFF0EE),
                                            child: Icon(Icons.store,
                                                color: const Color(0xFF5D201C),
                                                size: 24.sp),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 14.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Feito e entregue por',
                                              style: TextStyle(
                                                  color: Colors.grey.shade500,
                                                  fontSize: 11.sp),
                                            ),
                                            SizedBox(height: 2.h),
                                            Text(
                                              loja.nome,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15.sp,
                                                color: const Color(0xFF5D201C),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12.w, vertical: 6.h),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFF0EE),
                                          borderRadius:
                                              BorderRadius.circular(50.r),
                                        ),
                                        child: Text(
                                          'Ver loja',
                                          style: TextStyle(
                                            color: const Color(0xFFFF6961),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      SizedBox(height: 20.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F9F9),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Column(
                            children: [
                              _buildServiceRow(
                                  Icons.bolt, 'Envio imediato após a compra'),
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                child: Divider(
                                    height: 1.h,
                                    color: const Color(0xFFEEEEEE)),
                              ),
                              _buildServiceRow(Icons.check_circle_outline,
                                  'Garantia de reembolso em caso de problemas'),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Detalhes do Produto',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            produto.descricao.isNotEmpty
                                ? produto.descricao
                                : 'Este produto é preparado com ingredientes frescos e selecionados. Perfeito para qualquer momento do dia.',
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: Colors.black54,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 32.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('produtos')
                              .limit(5)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.waiting ||
                                !snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            final produtosRelacionados = snapshot.data!.docs
                                .map((doc) => ProdutosModel.fromMap(
                                    doc.data() as Map<String, dynamic>, doc.id))
                                .where((p) => p.uid != produto.uid)
                                .map((prod) => ProductSectionItem(
                                      idProduto: prod.uid,
                                      imageUrl: prod.imagemUrl.isNotEmpty
                                          ? prod.imagemUrl
                                          : 'https://via.placeholder.com/150',
                                      name: prod.nome,
                                      weight: '',
                                      price: prod.preco,
                                      lojaId: prod.lojaId,
                                      discountPercent: null,
                                    ))
                                .toList();

                            if (produtosRelacionados.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return HomeProductSection(
                              title: 'Produtos Relacionados',
                              products: produtosRelacionados,
                              onSeeAll: () {},
                            );
                          },
                        ),
                      ),
                      SizedBox(height: (100 + bottomPadding).h),
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
                left: 16.w,
                right: 16.w,
                top: 12.h,
                bottom: bottomPadding > 0 ? bottomPadding : 12.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10.r,
                    offset: Offset(0, -5.h),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildIconAction(Icons.star_border, 'Favoritar', '118'),
                  SizedBox(width: 16.w),
                  _buildIconAction(Icons.chat_bubble_outline, 'Chat', ''),
                  SizedBox(width: 24.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6961),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.r),
                        ),
                      ),
                      child: Text(
                        'Comprar  ${currencyFormat.format(produto.preco)}',
                        style: TextStyle(
                          fontSize: 16.sp,
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
        Icon(icon, size: 20.sp, color: const Color(0xFF888888)),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF555555),
            ),
          ),
        ),
        Icon(Icons.chevron_right, size: 20.sp, color: const Color(0xFFCCCCCC)),
      ],
    );
  }

  Widget _buildIconAction(IconData icon, String label, String count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24.sp, color: const Color(0xFF666666)),
        SizedBox(height: 4.h),
        Text(
          count.isNotEmpty ? count : label,
          style: TextStyle(
            fontSize: 11.sp,
            color: const Color(0xFF888888),
          ),
        ),
      ],
    );
  }

  Widget _buildLojaCardSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: 76.h,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(
          children: [
            Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r))),
            SizedBox(width: 14.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 100.w, height: 10.h, color: Colors.white),
                SizedBox(height: 6.h),
                Container(width: 140.w, height: 14.h, color: Colors.white),
              ],
            )
          ],
        ),
      ),
    );
  }
}
