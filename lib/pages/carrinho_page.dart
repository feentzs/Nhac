import 'package:flutter/material.dart';
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
  final Color lightAccentColor = const Color(0xFFFFEBD9);
  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE7E5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFE7E5),
        elevation: 0,
        title: const Text(
          'Carrinho',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
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
                  orElse: () => enderecoProvider.enderecos.first
                );

          return Stack(
            children: [
              ListView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 200),
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
                  const SizedBox(height: 16),
                  
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
                      children: cartProvider.itens.values.map((item) => _buildCartItem(item, cartProvider)).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
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
                  
                  const SizedBox(height: 24),
                  
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
                  
                  const SizedBox(height: 24),
                ],
              ),
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
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            'Seu carrinho está vazio',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection(EnderecoModel? address) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Endereço de entrega',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  address != null 
                      ? '${address.bairro} (${address.rua}, ${address.numero})' 
                      : 'Nenhum endereço selecionado',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey[100],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text(
              'Alterar',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.4 + (0.6 * t)),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.centerRight,
                              child: Transform.scale(
                                scale: 0.8 + (0.6 * t),
                                child: Opacity(
                                  opacity: (t * 2).clamp(0.0, 1.0),
                                  child: const Icon(
                                    Icons.delete_sweep_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        
                        Transform.translate(
                          offset: Offset(-slideValue * MediaQuery.of(context).size.width, 0),
                          child: Dismissible(
                            key: Key(item.idProduto),
                            direction: isProgrammaticDeleting ? DismissDirection.none : DismissDirection.endToStart,
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
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.4 + (0.6 * swipeProgress)),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.centerRight,
                              child: Transform.scale(
                                scale: 0.8 + (0.6 * swipeProgress),
                                child: Opacity(
                                  opacity: (swipeProgress * 2).clamp(0.0, 1.0),
                                  child: const Icon(
                                    Icons.delete_sweep_rounded,
                                    color: Colors.white,
                                    size: 28,
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
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(
                                            item.imagemUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
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
                                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      const SizedBox(height: 2),
                                                      const Text(
                                                        'Modelo: ÚNICO',
                                                        style: TextStyle(color: Colors.grey, fontSize: 12),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Row(
                                                        children: [
                                                          Container(
                                                            height: 32,
                                                            decoration: BoxDecoration(
                                                              border: Border.all(color: Colors.grey[300]!),
                                                              borderRadius: BorderRadius.circular(16),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                IconButton(
                                                                  padding: EdgeInsets.zero,
                                                                  constraints: const BoxConstraints(minWidth: 32),
                                                                  icon: const Icon(Icons.remove, size: 16),
                                                                  onPressed: () => cartProvider.removerItem(item.idProduto),
                                                                ),
                                                                Text(
                                                                  item.quantidade.toString(),
                                                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                                                ),
                                                                IconButton(
                                                                  padding: EdgeInsets.zero,
                                                                  constraints: const BoxConstraints(minWidth: 32),
                                                                  icon: const Icon(Icons.add, size: 16),
                                                                  onPressed: () => cartProvider.adicionarItem(
                                                                    idProduto: item.idProduto,
                                                                    nome: item.nome,
                                                                    preco: item.preco,
                                                                    imagemUrl: item.imagemUrl,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(width: 16),
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
                                                                fontSize: 13,
                                                                decoration: TextDecoration.underline,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      currencyFormat.format(item.preco),
                                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                                    ),
                                                    Text(
                                                      currencyFormat.format(item.preco * 1.1),
                                                      style: const TextStyle(
                                                        color: Colors.grey, 
                                                        fontSize: 12, 
                                                        decoration: TextDecoration.lineThrough
                                                      ),
                                                    ),
                                                    Container(
                                                      margin: const EdgeInsets.only(top: 4),
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: lightAccentColor,
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(Icons.loop, size: 12, color: primaryColor),
                                                          const SizedBox(width: 4),
                                                          Text(
                                                            currencyFormat.format(item.preco * 0.02),
                                                            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 10),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lightAccentColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.loop, color: primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 13),
                children: [
                  TextSpan(
                    text: '${currencyFormat.format(cashbackValue)} de cashback em 90 dias ',
                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumo do pedido',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Itens (${cartProvider.totalDeUnidades})', style: const TextStyle(color: Colors.grey)),
              Text(currencyFormat.format(cartProvider.valorTotal)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Frete', style: TextStyle(color: Colors.grey)),
              Text(
                'Grátis',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }


}
