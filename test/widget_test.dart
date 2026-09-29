import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shopping_list_app/models/item_category.dart';
import 'package:shopping_list_app/providers/shopping_list_provider.dart';
import 'package:shopping_list_app/screens/shopping_list_screen.dart';
import 'package:shopping_list_app/services/app_theme.dart';
import 'fake_repository.dart';

/// Test için minimal uygulama wrapper'ı.
Future<ShoppingListProvider> pumpApp(
  WidgetTester tester, [
  ShoppingListProvider? provider,
]) async {
  final repo = await createTestRepository();
  final p = provider ?? ShoppingListProvider(repo);

  await tester.pumpWidget(
    ChangeNotifierProvider<ShoppingListProvider>.value(
      value: p,
      child: MaterialApp(
        theme: AppTheme.light(),
        home: const ShoppingListScreen(),
      ),
    ),
  );
  return p;
}

void main() {
  group('ShoppingListScreen - empty state', () {
    testWidgets('Liste boşken empty state göstermeli', (tester) async {
      await pumpApp(tester);
      expect(find.text('Alışveriş listeniz boş'), findsOneWidget);
    });

    testWidgets('"İlk Ürünü Ekle" butonu görünmeli', (tester) async {
      await pumpApp(tester);
      expect(find.text('İlk Ürünü Ekle'), findsOneWidget);
    });
  });

  group('ShoppingListScreen - ürün listesi', () {
    testWidgets('Eklenen ürün ekranda görünmeli', (tester) async {
      final provider = await pumpApp(tester);

      await provider.addItem(
        name: 'Test Ürünü',
        quantity: 1.0,
        unit: 'adet',
        category: ItemCategory.other,
      );
      await tester.pump();

      expect(find.text('Test Ürünü'), findsOneWidget);
    });

    testWidgets('Özet banner ürün eklenince görünmeli', (tester) async {
      final provider = await pumpApp(tester);

      await provider.addItem(
        name: 'Süt',
        quantity: 2.0,
        unit: 'litre',
        category: ItemCategory.dairy,
      );
      await tester.pump();

      expect(find.text('Toplam 1 ürün'), findsOneWidget);
    });

    testWidgets('Checkbox tıklanınca isCompleted değişmeli', (tester) async {
      final provider = await pumpApp(tester);

      await provider.addItem(
        name: 'Ekmek',
        quantity: 1.0,
        unit: 'adet',
        category: ItemCategory.bakery,
      );
      await tester.pump();

      // Tamamlandı ikonu (radio_button_unchecked) bul
      expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);

      await tester.tap(find.byIcon(Icons.radio_button_unchecked));
      await tester.pump();

      // Artık check_circle gösterilmeli
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });

  group('ShoppingListScreen - arama', () {
    testWidgets('Arama simgesine tıklayınca arama moduna geçmeli',
        (tester) async {
      await pumpApp(tester);
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
    });
  });

  group('ShoppingListScreen - filtre', () {
    testWidgets('Filtre chip\'leri görünmeli', (tester) async {
      await pumpApp(tester);
      expect(find.text('Tümü (0)'), findsOneWidget);
      expect(find.text('Alınacaklar (0)'), findsOneWidget);
      expect(find.text('Tamamlananlar (0)'), findsOneWidget);
    });
  });
}
