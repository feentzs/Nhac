import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SetaVoltar extends StatelessWidget {
  final Color? cor;
  const SetaVoltar({super.key, this.cor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (GoRouter.of(context).canPop()) {
          GoRouter.of(context).pop();
        } else {
          GoRouter.of(context).go('/home-page');
        }
      },
      child: SizedBox(
        width: 21.w,
        height: 21.h,
        child: Icon(Icons.arrow_back_ios_new, color: cor ?? const Color(0xFF5D201C), size: 20.r),
      ),
    );
  }
}