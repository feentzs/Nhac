import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nhac/controllers/cart_provider.dart';
import 'package:nhac/models/produto/produtos.dart';
import 'package:provider/provider.dart';
import 'package:nhac/components/app_notification.dart';
import 'package:nhac/globals/ui_utils.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.produto,
    this.lojaFechada = false,
    this.onFlyToCart,
  });

  final ProdutosModel produto;
  final bool lojaFechada;
  /// Callback que recebe a posição global do botão "+" e a URL da imagem
  /// para disparar a animação fly-to-cart. Se null, não dispara animação.
  final void Function(Offset origin, String imageUrl)? onFlyToCart;

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
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                  child: CachedNetworkImage(
                    imageUrl: produto.imagemUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
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

              ],
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
                    Builder(
                      builder: (btnContext) {
                        return InkWell(
                          onTap: () async {
                            if (lojaFechada) {
                              context.showError('Esta loja está fechada no momento.');
                              return;
                            }

                            // Dispara animação fly-to-cart se callback estiver disponível
                            if (onFlyToCart != null) {
                              final renderBox = btnContext.findRenderObject() as RenderBox?;
                              if (renderBox != null && renderBox.attached) {
                                final origin = renderBox.localToGlobal(
                                  renderBox.size.center(Offset.zero),
                                );
                                onFlyToCart!(origin, produto.imagemUrl);
                              }
                            }

                            try {
                              final cartProvider = context.read<CartProvider>();
                              await cartProvider.adicionarItemComQuantidade(
                                idProduto: produto.id,
                                nome: produto.nome,
                                preco: produto.preco,
                                imagemUrl: produto.imagemUrl,
                                lojaId: produto.lojaId,
                                quantidade: 1,
                              );
                              if (context.mounted) {
                                showAppNotification(
                                  context,
                                  type: NotificationType.success,
                                  imageUrl: produto.imagemUrl,
                                  message: '${produto.nome} adicionado!',
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                context.showError(e.toString().replaceAll('Exception: ', ''));
                              }
                            }
                          },
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                            color: lojaFechada ? Colors.grey.shade400 : const Color(0xFF5D201C),
                            shape: BoxShape.circle),
                        child: Icon(Icons.add, color: Colors.white, size: 16.r),
                        ),
                        );
                      },
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
