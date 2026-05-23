import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NhacMenuTile extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final VoidCallback onTap;

  const NhacMenuTile({
    super.key,
    required this.titulo,
    this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 18.h),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF5D201C),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitulo != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    subtitulo!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16.r,
              color: const Color(0xFF5D201C),
            ),
          ],
        ),
      ),
    );
  }
}