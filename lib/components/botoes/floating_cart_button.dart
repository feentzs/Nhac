import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:nhac/controllers/cart_provider.dart';
import 'package:intl/intl.dart';

class FloatingCartButton extends StatelessWidget {
  const FloatingCartButton({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final isCartEmpty = cartProvider.itens.isEmpty;

    final router = GoRouter.of(context);
    final currentLocation = router.state.matchedLocation;
    if (currentLocation == '/carrinho' || isCartEmpty) {
      return const SizedBox.shrink();
    }

    final totalItens = cartProvider.totalDeUnidades;
    final totalPrice = cartProvider.valorTotal;
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Positioned(
      bottom: 20.h,
      right: 16.w,
      child: GestureDetector(
        onTap: () => context.push('/carrinho'),
        child: Container(
          height: 56.h,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFE645C),
            borderRadius: BorderRadius.circular(50.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$totalItens',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFE645C),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Ver sacola',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                currencyFormat.format(totalPrice),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}