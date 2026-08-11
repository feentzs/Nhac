import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shimmer/shimmer.dart';
import 'package:nhac/components/home/home_skeleton.dart';

void main() {
  testWidgets('HomeSkeleton deve renderizar shimmers corretamente', (tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => const MaterialApp(
          home: Scaffold(
            body: HomeSkeleton(),
          ),
        ),
      ),
    );

    expect(find.byType(Shimmer), findsAtLeastNWidgets(1));
  });
}
