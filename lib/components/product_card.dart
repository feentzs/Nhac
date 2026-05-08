import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nhac/controllers/cart_provider.dart';
import 'package:nowa_runtime/nowa_runtime.dart';
import 'package:provider/provider.dart';

@NowaGenerated()
class ProductCard extends StatelessWidget {
  @NowaGenerated({'loader': 'auto-constructor'})
  const ProductCard({
    super.key,
    required this.idProduto,
    required this.imageUrl,
    required this.name,
    required this.weight,
    required this.price,
  });

  final String idProduto;

  final String imageUrl;

  final String name;

  final String weight;

  final double price;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160.0,
      margin: const EdgeInsets.only(right: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF5D201C).withValues(alpha: 0.05),
            blurRadius: 10.0,
            offset: const Offset(0.0, 4.0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16.0),
              ),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    color: Colors.white,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: const Color(0xFFFFF0EE),
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: Color(0xFF5D201C),
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                    color: Color(0xFF5D201C),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4.0),
                Text(
                  weight,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12.0),
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'R\$ ${price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        color: Color(0xFF5D201C),
                      ),
                    ),
               InkWell(
  onTap: () {
    context.read<CartProvider>().adicionarItem(
      idProduto: idProduto,
      nome: name,
      preco: price,
      imagemUrl: imageUrl,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name adicionado ao carrinho!'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );
  },
  borderRadius: BorderRadius.circular(50.0), 
  child: Container(
    padding: const EdgeInsets.all(4.0),
    decoration: const BoxDecoration(
      color: Color(0xFF5D201C),
      shape: BoxShape.circle,
    ),
    child: const Icon(
      Icons.add,
      color: Colors.white,
      size: 16.0,
    ),
  ),
)],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
