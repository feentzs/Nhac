import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nhac/controllers/cart_provider.dart';
import 'package:nhac/controllers/endereco_provider.dart';
import 'package:nhac/models/usuario/carrinho_model.dart';
import 'package:nhac/models/usuario/endereco_model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class CarrinhoPage extends StatefulWidget {
  final bool isActive;
  const CarrinhoPage({super.key, this.isActive = true});

  @override
  State<CarrinhoPage> createState() => _CarrinhoPageState();
}

class _CarrinhoPageState extends State<CarrinhoPage> {
  final Color primaryColor = const Color(0xFFFF6961);
  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE7E5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFE7E5),
        elevation: 0,
        title: Text(
          'Carrinho',
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp),
        ),
        centerTitle: true,
      ),
      body: Consumer2<CartProvider, EnderecoProvider>(
        builder: (context, cartProvider, enderecoProvider, child) {
          if (cartProvider.itens.isEmpty) {
            return _buildEmptyCart();
          }

          final defaultAddress = enderecoProvider.enderecos.isEmpty
              ? null
              : enderecoProvider.enderecos.firstWhere(
                  (e) => e.padrao,
                  orElse: () => enderecoProvider.enderecos.first,
                );

          return Column(
            children: [
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                  children: [
                    SizedBox(height: 8.h),
                    _buildAddressSection(context, defaultAddress),
                    SizedBox(height: 24.h),
                    ...cartProvider.itens.values
                        .map((item) => _buildCartItem(item, cartProvider))
                        ,
                  ],
                ),
              ),
              _buildBottomButton(cartProvider),
            ],
          );
        },
      ),
    );
  }


  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80.r, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            'Seu carrinho está vazio',
            style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection(BuildContext context, EnderecoModel? address) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6961).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.location_on_outlined, color: primaryColor, size: 20.r),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Endereço de entrega',
                  style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                ),
                SizedBox(height: 4.h),
                Text(
                  address != null
                      ? '${address.rua}, ${address.numero} - ${address.bairro}'
                      : 'Nenhum endereço selecionado',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      color: const Color(0xFF5D201C)),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _mostrarSelecaoEndereco(context),
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey[100],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r)),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
            ),
            child: Text(
              'Alterar',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _mostrarSelecaoEndereco(BuildContext context) async {
    final enderecoProvider = context.read<EnderecoProvider>();
    final enderecos = enderecoProvider.enderecos;

    if (enderecos.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
          title: const Text('Nenhum endereço salvo'),
          content: const Text(
              'Você ainda não possui endereços cadastrados. Deseja adicionar um agora?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
context.push('/enderecos-salvos');              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFE645C),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: const Text('Adicionar'),
            ),
          ],
        ),
      );
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddressSelectionSheet(enderecos: enderecos),
    );
    await enderecoProvider.iniciarEscutaEnderecos();
    setState(() {});
  }

  Widget _buildBottomButton(CartProvider cartProvider) {
  return Padding(
    padding: EdgeInsets.only(bottom: 80.h),
    child: Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total', style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                Text(
                  currencyFormat.format(cartProvider.valorTotal),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                    color: const Color(0xFF5D201C),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 140.w,
            height: 49.h,
            child: ElevatedButton(
              onPressed: () => context.push('/checkout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFE645C),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.r)),
              ),
              child: Text('Continuar', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildCartItem(CarrinhoModel item, CartProvider cartProvider) {
    double swipeProgress = 0.0;
    bool hasVibrated = false;
    bool isProgrammaticDeleting = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: isProgrammaticDeleting ? 500 : 0),
          curve: Curves.easeOutQuart,
          tween: Tween(begin: 0.0, end: isProgrammaticDeleting ? 1.0 : 0.0),
          onEnd: () {
            if (isProgrammaticDeleting) {
              cartProvider.excluirItemDoCarrinho(item.idProduto);
            }
          },
          builder: (context, t, child) {
            double slideValue = (t / 0.6).clamp(0.0, 1.0);
            double heightValue = 1.0 - ((t - 0.15) / 0.85).clamp(0.0, 1.0);
            double opacityValue = (1.0 - (t / 0.4)).clamp(0.0, 1.0);

            return ClipRect(
              child: Align(
                heightFactor: isProgrammaticDeleting ? heightValue : 1.0,
                alignment: Alignment.topCenter,
                child: Stack(
                  children: [
                    if (isProgrammaticDeleting)
                      Positioned.fill(
                        child: Container(
                          margin: EdgeInsets.only(bottom: 16.h),
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.4 + (0.6 * t)),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          alignment: Alignment.centerRight,
                          child: Transform.scale(
                            scale: 0.8 + (0.6 * t),
                            child: Opacity(
                              opacity: (t * 2).clamp(0.0, 1.0),
                              child: Icon(
                                Icons.delete_sweep_rounded,
                                color: Colors.white,
                                size: 28.r,
                              ),
                            ),
                          ),
                        ),
                      ),
                    Transform.translate(
                      offset: Offset(-slideValue * MediaQuery.of(context).size.width, 0),
                      child: Dismissible(
                        key: Key(item.idProduto),
                        direction: isProgrammaticDeleting
                            ? DismissDirection.none
                            : DismissDirection.endToStart,
                        resizeDuration: const Duration(milliseconds: 350),
                        movementDuration: const Duration(milliseconds: 350),
                        onUpdate: (details) {
                          setState(() {
                            swipeProgress = details.progress;
                          });
                          if (details.reached && !hasVibrated) {
                            HapticFeedback.mediumImpact();
                            hasVibrated = true;
                          } else if (!details.reached) {
                            hasVibrated = false;
                          }
                        },
                        onDismissed: (direction) {
                          if (!isProgrammaticDeleting) {
                            cartProvider.excluirItemDoCarrinho(item.idProduto);
                          }
                        },
                        background: Container(
                          margin: EdgeInsets.only(bottom: 16.h),
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.4 + (0.6 * swipeProgress)),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          alignment: Alignment.centerRight,
                          child: Transform.scale(
                            scale: 0.8 + (0.6 * swipeProgress),
                            child: Opacity(
                              opacity: (swipeProgress * 2).clamp(0.0, 1.0),
                              child: Icon(
                                Icons.delete_sweep_rounded,
                                color: Colors.white,
                                size: 28.r,
                              ),
                            ),
                          ),
                        ),
                        child: Transform.scale(
                          scale: isProgrammaticDeleting
                              ? (1.0 - (slideValue * 0.12)).clamp(0.88, 1.0)
                              : (1.0 - (swipeProgress * 0.1)).clamp(0.9, 1.0),
                          child: Opacity(
                            opacity: isProgrammaticDeleting
                                ? opacityValue
                                : (1.0 - (swipeProgress * 1.8)).clamp(0.0, 1.0),
                            child: Container(
                              margin: EdgeInsets.only(bottom: 16.h),
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10.r,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 80.w,
                                    height: 80.w,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12.r),
                                      child: Image.network(
                                        item.imagemUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            Icon(Icons.image, color: Colors.grey, size: 24.r),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item.nome,
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14.sp),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(height: 8.h),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        height: 32.h,
                                                        decoration: BoxDecoration(
                                                          border: Border.all(color: Colors.grey[300]!),
                                                          borderRadius: BorderRadius.circular(16.r),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            IconButton(
                                                              padding: EdgeInsets.zero,
                                                              constraints: const BoxConstraints(minWidth: 32),
                                                              icon: Icon(Icons.remove, size: 16.r),
                                                              onPressed: () =>
                                                                  cartProvider.removerItem(item.idProduto),
                                                            ),
                                                            Text(
                                                              item.quantidade.toString(),
                                                              style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 14.sp),
                                                            ),
                                                            IconButton(
                                                              padding: EdgeInsets.zero,
                                                              constraints: const BoxConstraints(minWidth: 32),
                                                              icon: Icon(Icons.add, size: 16.r),
                                                              onPressed: () =>
                                                                  cartProvider.adicionarItem(
                                                                    idProduto: item.idProduto,
                                                                    nome: item.nome,
                                                                    preco: item.preco,
                                                                    imagemUrl: item.imagemUrl,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(width: 16.w),
                                                      GestureDetector(
                                                        onTap: () {
                                                          HapticFeedback.lightImpact();
                                                          setState(() {
                                                            isProgrammaticDeleting = true;
                                                          });
                                                        },
                                                        child: Text(
                                                          'Excluir',
                                                          style: TextStyle(
                                                            color: primaryColor,
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 13.sp,
                                                            decoration: TextDecoration.underline,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  currencyFormat.format(item.preco),
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14.sp),
                                                ),
                                                SizedBox(height: 4.h),
                                                Text(
                                                  '${item.quantidade} un',
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12.sp),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 16.h),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}


class _AddressSelectionSheet extends StatelessWidget {
  final List<EnderecoModel> enderecos;

  const _AddressSelectionSheet({required this.enderecos});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      padding: EdgeInsets.only(top: 16.h, bottom: 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Selecione o endereço de entrega',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF5D201C),
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              itemCount: enderecos.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final endereco = enderecos[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: () async {
                    await context
                        .read<EnderecoProvider>()
                        .definirComoPadrao(endereco.idDocumento);
                    if (context.mounted) Navigator.pop(context);
                  },
                  leading: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6961).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      endereco.bairro.toLowerCase().contains('trabalho') ||
                              endereco.complemento.toLowerCase().contains('trabalho')
                          ? Icons.work_outline
                          : Icons.home_outlined,
                      color: const Color(0xFFFF6961),
                      size: 20.r,
                    ),
                  ),
                  title: Text(
                    '${endereco.rua}, ${endereco.numero}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
                  ),
                  subtitle: Text(
                    '${endereco.bairro}${endereco.complemento.isNotEmpty ? ' - ${endereco.complemento}' : ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13.sp),
                  ),
                  trailing: endereco.padrao
                      ? Icon(Icons.check_circle, color: const Color(0xFFFF6961), size: 22.r)
                      : null,
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: const Divider(height: 32),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: InkWell(
              onTap: () {
context.push('/enderecos-salvos');              },
              borderRadius: BorderRadius.circular(12.r),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.add, color: Colors.grey, size: 20.r),
                    ),
                    SizedBox(width: 16.w),
                    Text(
                      'Adicionar novo endereço',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}