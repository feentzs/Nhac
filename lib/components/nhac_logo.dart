import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nowa_runtime/nowa_runtime.dart';

@NowaGenerated({'auto-width': 132, 'auto-height': 49})
class NhacLogo extends StatelessWidget {
  @NowaGenerated({'loader': 'auto-constructor'})
  const NhacLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image(
      image: const AssetImage('assets/nhac-logo.png'),
      fit: BoxFit.contain,
      width: 132.w,
      height: 49.h,
    );
  }
}