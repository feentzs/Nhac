import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nhac/controllers/cart_provider.dart';
import 'package:nhac/models/produto/produtos.dart';
import 'package:provider/provider.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.produto,
  });

  final ProdutosModel produto;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160.w,
      margin: EdgeInsets.only(right: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5D201C).withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              child: CachedNetworkImage(
                imageUrl: produto.imagemUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(color: Colors.white),
                ),
                errorWidget: (context, url, error) => Container(
                  color: const Color(0xFFFFF0EE),
                  child: Icon(Icons.image_not_supported_outlined,
                      color: const Color(0xFF5D201C), size: 32.r),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produto.nome,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      color: const Color(0xFF5D201C)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text("500g",
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 12.sp)),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'R\$ ${produto.preco.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                            color: const Color(0xFF5D201C)),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        try {
                          await context
                              .read<CartProvider>()
                              .adicionarItemComQuantidade(
                                idProduto: produto.id,
                                nome: produto.nome,
                                preco: produto.preco,
                                imagemUrl: produto.imagemUrl,
                                quantidade: 1,
                              );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('${produto.nome} adicionado!'),
                                  backgroundColor: Colors.green),
                            );
                          }
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: Colors.red),
                          );
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: const BoxDecoration(
                            color: Color(0xFF5D201C), shape: BoxShape.circle),
                        child: Icon(Icons.add, color: Colors.white, size: 16.r),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
