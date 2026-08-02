import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nhac/pages/search_page.dart';

void main() {
  Widget createWidgetUnderTest() {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => const MaterialApp(
        home: SearchPage(),
      ),
    );
  }

  testWidgets('SearchPage deve renderizar o campo de busca e aceitar input', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Pesquisar produtos...'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Pizza');
    expect(find.text('Pizza'), findsOneWidget);
  });
}
