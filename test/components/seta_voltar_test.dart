import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nhac/components/seta_voltar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';

class MockGoRouter extends Mock implements GoRouter {}

void main() {
  testWidgets('Deve renderizar a SetaVoltar corretamente', (tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => const MaterialApp(
          home: Scaffold(
            body: SetaVoltar(),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
  });
}
