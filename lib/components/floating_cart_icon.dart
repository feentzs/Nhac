import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:nhac/controllers/cart_provider.dart';

class FloatingCartIcon extends StatelessWidget {
  final VoidCallback? onPressed;
  const FloatingCartIcon({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final totalItens = cartProvider.totalDeUnidades;
    if (totalItens == 0) return const SizedBox.shrink();

    return Positioned(
      bottom: 20.h,
      right: 16.w,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 56.w,
          height: 56.h,
          decoration: BoxDecoration(
            color: const Color(0xFFFE645C),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Stack(
            children: [
              const Center(
                child: Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 28),
              ),
              if (totalItens > 0)
                Positioned(
                  right: 8.w,
                  top: 8.h,
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF6961),
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(minWidth: 18.w, minHeight: 18.h),
                    child: Text(
                      '$totalItens',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}