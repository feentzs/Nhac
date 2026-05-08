import 'package:flutter/material.dart';
import 'package:nhac/components/product_card.dart';

class ProductSectionItem {
  const ProductSectionItem({
    required this.idProduto,
    required this.imageUrl,
    required this.name,
    required this.weight,
    required this.price,
    this.discountPercent,
  });

  final String idProduto;
  final String imageUrl;
  final String name;
  final String weight;
  final double price;
  final int? discountPercent;
}

class HomeProductSection extends StatelessWidget {
  const HomeProductSection({
    super.key,
    required this.title,
    required this.products,
    this.onSeeAll,
  });

  final String title;
  final List<ProductSectionItem> products;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: Color(0xFF5D201C),
              ),
            ),
            GestureDetector(
              onTap: onSeeAll,
              child: const Text(
                'Ver tudo',
                style: TextStyle(
                  color: Color(0xFFFF6961),
                  fontWeight: FontWeight.w600,
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        SizedBox(
          height: 220.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            clipBehavior: Clip.none,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final item = products[index];
              return Stack(
                children: [
                  ProductCard(
                    idProduto: item.idProduto,
                    imageUrl: item.imageUrl,
                    name: item.name,
                    weight: item.weight,
                    price: item.price,
                  ),
                  if (item.discountPercent != null)
                    Positioned(
                      top: 8.0,
                      left: 8.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 3.0,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6961),
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        child: Text(
                          '${item.discountPercent}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10.0,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
