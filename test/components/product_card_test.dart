import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:provider/provider.dart'; 
import 'package:nhac/components/product_card.dart';
import 'package:nhac/controllers/cart_provider.dart'; 

void main() {
  testWidgets('Deve exibir corretamente os dados do ProductCard e aceitar o clique', (WidgetTester tester) async {
    
    await mockNetworkImagesFor(() async {
      
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
          child: const MaterialApp(
            home: Scaffold(
              body: ProductCard(
                idProduto: 'hamburguer-123', 
                imageUrl: 'https://via.placeholder.com/150', 
                name: 'Hambúrguer Teste',
                weight: '250g',
                price: 29.90,
                lojaId: 'id22',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Hambúrguer Teste'), findsOneWidget);
      expect(find.text('250g'), findsOneWidget);
      expect(find.text('\$29.90'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump(); 
      
    }); 
  });
}