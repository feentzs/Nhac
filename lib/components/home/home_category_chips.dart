import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class HomeCategoryChips extends StatelessWidget {
  const HomeCategoryChips({super.key});

  // BUG CORRIGIDO: essas categorias eram categorias de LOJA (loja.categoria:
  // Japonesa, Italiana, Brasileira...), não de PRODUTO (produto.categoriaMenu)
  // — e o filtro da busca usa categoriaMenu. "Mercado" nem existia em
  // nenhum dos dois. Trocado pelas categorias de produto reais.
  static const _categorias = [
    {'nome': 'Combos', 'icon': Icons.fastfood},
    {'nome': 'Prato Principal', 'icon': Icons.restaurant},
    {'nome': 'Acompanhamento', 'icon': Icons.rice_bowl},
    {'nome': 'Sobremesas', 'icon': Icons.icecream},
    {'nome': 'Bebidas', 'icon': Icons.local_drink},
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
                final categoriaCodificada = Uri.encodeComponent(cat['nome'] as String);
                context.push('/search?categoria=$categoriaCodificada');
              },
            ),
          );
        },
      ),
    );
  }
}
