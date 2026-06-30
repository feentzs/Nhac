import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nhac/models/loja/lojas.dart';

class HomeLojaCard extends StatelessWidget {
  final LojasModel loja;
  final VoidCallback onTap;

  const HomeLojaCard({super.key, required this.loja, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                image: DecorationImage(
                  image: NetworkImage(loja.imagemUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(loja.nome, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                  Text(loja.categoria, style: TextStyle(color: Colors.grey, fontSize: 13.sp)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
