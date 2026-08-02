import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shimmer/shimmer.dart';

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(width: 80.w, height: 80.h, color: Colors.white),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: double.infinity, height: 12.h, color: Colors.white),
                    SizedBox(height: 8.h),
                    Container(width: 150.w, height: 12.h, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
