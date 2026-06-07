import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nhac/components/product_card.dart';
import 'package:nhac/controllers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';

class MockCartProvider extends Mock implements CartProvider {}

void main() {
  late MockCartProvider mockCart;

  setUp(() {
    mockCart = MockCartProvider();
  });

  Widget createWidgetUnderTest() {
    return ScreenUtilInit(
      designSize: const Size(1000, 1000), // Tamanho grande para evitar overflows em testes unitários
      minTextAdapt: true,
      builder: (context, child) => MultiProvider(
        providers: [
          ChangeNotifierProvider<CartProvider>.value(value: mockCart),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400, // Largura ampla
                height: 500,
                child: ProductCard(
                  idProduto: 'p1',
                  imageUrl: 'http://example.com/image.png',
                  name: 'Nhac Burger',
                  weight: '500g',
                  price: 35.90,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('Deve exibir corretamente os dados do ProductCard', (tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Nhac Burger'), findsOneWidget);
      expect(find.text('500g'), findsOneWidget);
      expect(find.text('R\$ 35.90'), findsOneWidget);
    });
  });

  testWidgets('Deve chamar adicionarItem ao clicar no botão de adicionar', (tester) async {
    registerFallbackValue('p1');
    when(() => mockCart.adicionarItem(
          idProduto: any(named: 'idProduto'),
          nome: any(named: 'nome'),
          preco: any(named: 'preco'),
          imagemUrl: any(named: 'imagemUrl'),
        )).thenAnswer((_) async {});

    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final addIcon = find.byIcon(Icons.add);
      await tester.tap(addIcon, warnIfMissed: false);
      await tester.pump();

      verify(() => mockCart.adicionarItem(
            idProduto: 'p1',
            nome: 'Nhac Burger',
            preco: 35.90,
            imagemUrl: 'http://example.com/image.png',
          )).called(1);
      
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Nhac Burger adicionado ao carrinho!'), findsOneWidget);
    });
  });
}
