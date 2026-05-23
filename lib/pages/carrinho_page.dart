import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nhac/controllers/cart_provider.dart';
import 'package:nhac/controllers/endereco_provider.dart';
import 'package:nhac/models/usuario/carrinho_model.dart';
import 'package:nhac/models/usuario/endereco_model.dart';
import 'package:nhac/pages/formas_pagamento_page.dart';
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
  final Color lightAccentColor = const Color(0xFFFFEBD9);
  final NumberFormat currencyFormat =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  final TextEditingController _observacaoController = TextEditingController();
  String _formaPagamentoSelecionada = 'Selecionar forma de pagamento';
  IconData _iconePagamentoSelecionado = Icons.payment_outlined;

  @override
  void dispose() {
    _observacaoController.dispose();
    super.dispose();
  }

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

          return Stack(
            children: [
              ListView(
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 200.h),
                children: [
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 600),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, -20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: _buildAddressSection(defaultAddress),
                  ),
                  const Divider(height: 1),
                  SizedBox(height: 16.h),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 700),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: const Interval(0.2, 0.9, curve: Curves.easeOutCubic),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, -20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      children: cartProvider.itens.values
                          .map((item) => _buildCartItem(item, cartProvider))
                          .toList(),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 750),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)), child: child),
                      );
                    },
                    child: _buildObservacaoField(),
                  ),
                  SizedBox(height: 24.h),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)), child: child),
                      );
                    },
                    child: _buildPaymentSection(context),
                  ),
                  SizedBox(height: 24.h),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 850),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: _buildCashbackBanner(cartProvider.valorTotal * 0.02),
                  ),
                  SizedBox(height: 24.h),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 900),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: _buildOrderSummary(cartProvider),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildObservacaoField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Observações para o restaurante',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.sp,
              color: const Color(0xFF5D201C)),
        ),
        SizedBox(height: 12.h),
        TextField(
          controller: _observacaoController,
          maxLines: 2,
          maxLength: 140,
          decoration: InputDecoration(
            hintText: 'Ex: Tirar cebola, maionese à parte, troco para R\$ 50...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.all(16.w),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide:
                  BorderSide(color: primaryColor.withValues(alpha: 0.5)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10.r,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: lightAccentColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(_iconePagamentoSelecionado, color: primaryColor),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pagamento na entrega',
                  style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                ),
                SizedBox(height: 4.h),
                Text(
                  _formaPagamentoSelecionada,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      color: const Color(0xFF5D201C)),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              final resultado = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const FormasPagamentoPage()),
              );

              if (resultado != null && resultado is String) {
                setState(() {
                  _formaPagamentoSelecionada = resultado;
                  if (resultado.toLowerCase().contains('pix')) {
                    _iconePagamentoSelecionado = Icons.pix;
                  } else if (resultado.toLowerCase().contains('dinheiro')) {
                    _iconePagamentoSelecionado = Icons.money;
                  } else {
                    _iconePagamentoSelecionado = Icons.credit_card;
                  }
                });
              }
            },
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

  Widget _buildAddressSection(EnderecoModel? address) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      ? '${address.bairro} (${address.rua}, ${address.numero})'
                      : 'Nenhum endereço selecionado',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14.sp),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
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

  Widget _buildCartItem(CarrinhoModel item, CartProvider cartProvider) {
    double swipeProgress = 0.0;
    bool hasVibrated = false;
    bool isProgrammaticDeleting = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return TweenAnimationBuilder<double>(
          duration:
              Duration(milliseconds: isProgrammaticDeleting ? 500 : 0),
          curve: Curves.easeOutQuart,
          tween: Tween(
              begin: 0.0, end: isProgrammaticDeleting ? 1.0 : 0.0),
          onEnd: () {
            if (isProgrammaticDeleting) {
              cartProvider.excluirItemDoCarrinho(item.idProduto);
            }
          },
          builder: (context, t, child) {
            double slideValue = (t / 0.6).clamp(0.0, 1.0);
            double heightValue =
                1.0 - ((t - 0.15) / 0.85).clamp(0.0, 1.0);
            double opacityValue = (1.0 - (t / 0.4)).clamp(0.0, 1.0);

            return ClipRect(
              child: Align(
                heightFactor:
                    isProgrammaticDeleting ? heightValue : 1.0,
                alignment: Alignment.topCenter,
                child: Stack(
                  children: [
                    if (isProgrammaticDeleting)
                      Positioned.fill(
                        child: Container(
                          margin: EdgeInsets.only(bottom: 16.h),
                          padding:
                              EdgeInsets.symmetric(horizontal: 24.w),
                          decoration: BoxDecoration(
                            color: primaryColor
                                .withValues(alpha: 0.4 + (0.6 * t)),
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
                      offset: Offset(
                          -slideValue *
                              MediaQuery.of(context).size.width,
                          0),
                      child: Dismissible(
                        key: Key(item.idProduto),
                        direction: isProgrammaticDeleting
                            ? DismissDirection.none
                            : DismissDirection.endToStart,
                        resizeDuration:
                            const Duration(milliseconds: 350),
                        movementDuration:
                            const Duration(milliseconds: 350),
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
                            cartProvider
                                .excluirItemDoCarrinho(item.idProduto);
                          }
                        },
                        background: Container(
                          margin: EdgeInsets.only(bottom: 16.h),
                          padding:
                              EdgeInsets.symmetric(horizontal: 24.w),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(
                                alpha: 0.4 + (0.6 * swipeProgress)),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          alignment: Alignment.centerRight,
                          child: Transform.scale(
                            scale: 0.8 + (0.6 * swipeProgress),
                            child: Opacity(
                              opacity:
                                  (swipeProgress * 2).clamp(0.0, 1.0),
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
                              ? (1.0 - (slideValue * 0.12))
                                  .clamp(0.88, 1.0)
                              : (1.0 - (swipeProgress * 0.1))
                                  .clamp(0.9, 1.0),
                          child: Opacity(
                            opacity: isProgrammaticDeleting
                                ? opacityValue
                                : (1.0 - (swipeProgress * 1.8))
                                    .clamp(0.0, 1.0),
                            child: Container(
                              margin: EdgeInsets.only(bottom: 16.h),
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(16.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withValues(alpha: 0.05),
                                    blurRadius: 10.r,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 80.w,
                                    height: 80.w,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius:
                                          BorderRadius.circular(12.r),
                                    ),
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(12.r),
                                      child: Image.network(
                                        item.imagemUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error,
                                                stackTrace) =>
                                            Icon(Icons.image,
                                                color: Colors.grey,
                                                size: 24.r),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                children: [
                                                  Text(
                                                    item.nome,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight
                                                                .bold,
                                                        fontSize:
                                                            14.sp),
                                                    maxLines: 2,
                                                    overflow: TextOverflow
                                                        .ellipsis,
                                                  ),
                                                  SizedBox(height: 2.h),
                                                  Text(
                                                    'Modelo: ÚNICO',
                                                    style: TextStyle(
                                                        color:
                                                            Colors.grey,
                                                        fontSize:
                                                            12.sp),
                                                  ),
                                                  SizedBox(height: 8.h),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        height: 32.h,
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              color: Colors
                                                                  .grey[300]!),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      16.r),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            IconButton(
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              constraints:
                                                                  BoxConstraints(
                                                                      minWidth:
                                                                          32.w),
                                                              icon: Icon(
                                                                  Icons
                                                                      .remove,
                                                                  size:
                                                                      16.r),
                                                              onPressed: () =>
                                                                  cartProvider
                                                                      .removerItem(
                                                                          item.idProduto),
                                                            ),
                                                            Text(
                                                              item.quantidade
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      14.sp),
                                                            ),
                                                            IconButton(
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              constraints:
                                                                  BoxConstraints(
                                                                      minWidth:
                                                                          32.w),
                                                              icon: Icon(
                                                                  Icons.add,
                                                                  size:
                                                                      16.r),
                                                              onPressed:
                                                                  () => cartProvider
                                                                      .adicionarItem(
                                                                        idProduto:
                                                                            item.idProduto,
                                                                        nome:
                                                                            item.nome,
                                                                        preco:
                                                                            item.preco,
                                                                        imagemUrl:
                                                                            item.imagemUrl,
                                                                      ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(width: 16.w),
                                                      GestureDetector(
                                                        onTap: () {
                                                          HapticFeedback
                                                              .lightImpact();
                                                          setState(() {
                                                            isProgrammaticDeleting =
                                                                true;
                                                          });
                                                        },
                                                        child: Text(
                                                          'Excluir',
                                                          style: TextStyle(
                                                            color:
                                                                primaryColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                            fontSize: 13.sp,
                                                            decoration:
                                                                TextDecoration
                                                                    .underline,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 8.w),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  currencyFormat
                                                      .format(item.preco),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14.sp),
                                                ),
                                                Text(
                                                  currencyFormat.format(
                                                      item.preco * 1.1),
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12.sp,
                                                    decoration:
                                                        TextDecoration
                                                            .lineThrough,
                                                  ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      top: 4.h),
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 6.w,
                                                      vertical: 2.h),
                                                  decoration: BoxDecoration(
                                                    color: lightAccentColor,
                                                    borderRadius:
                                                        BorderRadius
                                                            .circular(4.r),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(Icons.loop,
                                                          size: 12.r,
                                                          color: primaryColor),
                                                      SizedBox(width: 4.w),
                                                      Text(
                                                        currencyFormat.format(
                                                            item.preco *
                                                                0.02),
                                                        style: TextStyle(
                                                            color:
                                                                primaryColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                            fontSize: 10.sp),
                                                      ),
                                                    ],
                                                  ),
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

  Widget _buildCashbackBanner(double cashbackValue) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: lightAccentColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.loop, color: primaryColor),
          SizedBox(width: 12.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.black, fontSize: 13.sp),
                children: [
                  TextSpan(
                    text:
                        '${currencyFormat.format(cashbackValue)} de cashback em 90 dias ',
                    style: TextStyle(
                        color: primaryColor, fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: 'após o pagamento'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cartProvider) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo do pedido',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Itens (${cartProvider.totalDeUnidades})',
                  style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
              Text(currencyFormat.format(cartProvider.valorTotal),
                  style: TextStyle(fontSize: 14.sp)),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Frete',
                  style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
              Text(
                'Grátis',
                style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }
}