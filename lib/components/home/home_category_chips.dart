import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class HomeCategoryChips extends StatelessWidget {
  const HomeCategoryChips({super.key});

  static const _categorias = [
    {'nome': 'Mercado', 'icon': Icons.shopping_basket},
    {'nome': 'Lanches', 'icon': Icons.fastfood},
    {'nome': 'Pizza',   'icon': Icons.local_pizza},
    {'nome': 'Saudável','icon': Icons.eco},
    {'nome': 'Doces',   'icon': Icons.icecream},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categorias.length,
        itemBuilder: (context, index) {
          final cat = _categorias[index];
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: ActionChip(
              label: Text(cat['nome'] as String),
              avatar: Icon(cat['icon'] as IconData, size: 16.r),
              onPressed: () {
                context.push('/search?categoria=${cat['nome']}');
              },
            ),
          );
        },
      ),
    );
  }
}
