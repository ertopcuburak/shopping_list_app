import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_list_app/models/item_category.dart';
import 'package:shopping_list_app/models/shopping_item.dart';

void main() {
  group('ItemCategory', () {
    test('Tüm kategorilerin label değeri boş olmamalı', () {
      for (final category in ItemCategory.values) {
        expect(category.label, isNotEmpty);
      }
    });

    test('Tüm kategorilerin emoji değeri boş olmamalı', () {
      for (final category in ItemCategory.values) {
        expect(category.emoji, isNotEmpty);
      }
    });

    test('fromKey bilinen kategoriyi döndürmeli', () {
      expect(ItemCategory.fromKey('dairy'), equals(ItemCategory.dairy));
      expect(ItemCategory.fromKey('bakery'), equals(ItemCategory.bakery));
    });

    test('fromKey bilinmeyen key için other dönmeli', () {
      expect(ItemCategory.fromKey('bilinmeyen'), equals(ItemCategory.other));
    });

    test('key / fromKey round-trip tutarlı olmalı', () {
      for (final category in ItemCategory.values) {
        expect(ItemCategory.fromKey(category.key), equals(category));
      }
    });
  });

  group('ShoppingItem JSON round-trip tüm kategorilerle', () {
    test('Tüm kategorilerle serializasyon çalışmalı', () {
      for (final category in ItemCategory.values) {
        final item = ShoppingItem.create(
          name: 'Test',
          quantity: 1.0,
          unit: 'adet',
          category: category,
        );
        final json = item.toJson();
        final restored = ShoppingItem.fromJson(json);
        expect(restored.category, equals(category));
      }
    });
  });
}
