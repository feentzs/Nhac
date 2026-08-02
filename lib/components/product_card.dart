import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nhac/controllers/cart_provider.dart';
import 'package:nhac/models/produto/produtos.dart';
import 'package:nhac/services/loja_status_service.dart';
import 'package:provider/provider.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.produto,
    this.lojaFechada,
  });

  final ProdutosModel produto;
  // BUG CORRIGIDO: "loja fechada deve explicitar que tá fechada e não
  // permitir colocar itens no carrinho". Antes o card não sabia nada
  // sobre o status da loja — o usuário só descobria no 404 ao finalizar
  // o pedido, depois de todo o fluxo de checkout.
  //
  // Agora é opcional (bool?): quando quem chama JÁ SABE o status (ex:
  // loja_page.dart, que já carregou a loja inteira), passa o valor direto
  // e nenhuma consulta extra é feita. Quando não é passado (Home, busca —
  // onde não há a loja carregada por perto), o card resolve sozinho via
  // LojaStatusService, usando só o lojaId, com cache — sem precisar de
  // nenhum campo novo do backend.
  final bool? lojaFechada;

  @override
  Widget build(BuildContext context) {
    if (lojaFechada != null) {
      return _buildCard(context, lojaFechada!);
    }

    return FutureBuilder<bool>(
      future: LojaStatusService().isLojaAberta(produto.lojaId),
      builder: (context, snapshot) {
        // Enquanto carrega (ou se a checagem falhar por algum motivo
        // inesperado), assume aberta — evita que todo card pisque como
        // "fechado" por uma fração de segundo a cada carregamento.
        final fechada = snapshot.hasData && snapshot.data == false;
        return _buildCard(context, fechada);
      },
    );
  }

  Widget _buildCard(BuildContext context, bool lojaFechada) {
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
                      onTap: lojaFechada
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Essa loja está fechada no momento. Não é possível adicionar itens.')),
                              );
                            }
                          : () async {
                        final cartProvider = context.read<CartProvider>();
                        final success = await cartProvider.adicionarItemComQuantidade(
                          idProduto: produto.id,
                          nome: produto.nome,
                          preco: produto.preco,
                          imagemUrl: produto.imagemUrl,
                          lojaId: produto.lojaId,
                          quantidade: 1,
                        );
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${produto.nome} adicionado ao carrinho!')),
                          );
                        } else if (!success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Você já possui itens de outra loja no carrinho!')),
                          );
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                            color: lojaFechada ? Colors.grey.shade400 : const Color(0xFF5D201C),
                            shape: BoxShape.circle),
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
