import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:nhac/controllers/cart_provider.dart';

class FloatingCartButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const FloatingCartButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        if (cart.totalDeUnidades == 0) return const SizedBox.shrink();

        return Positioned(
          bottom: 80.h,
          right: 16.w,
          child: GestureDetector(
            onTap: onPressed ?? () => Navigator.pushNamed(context, '/carrinho'),
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6961),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 28.r),
                  Positioned(
                    top: -4.h,
                    right: -4.w,
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${cart.totalDeUnidades}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFF6961),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}