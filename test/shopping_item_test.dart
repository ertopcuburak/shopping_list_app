import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_list_app/models/item_category.dart';
import 'package:shopping_list_app/models/shopping_item.dart';

void main() {
  group('ShoppingItem', () {
    ShoppingItem createSample({
      String name = 'Süt',
      double quantity = 2.0,
      String unit = 'litre',
      ItemCategory category = ItemCategory.dairy,
      String? note,
    }) {
      return ShoppingItem.create(
        name: name,
        quantity: quantity,
        unit: unit,
        category: category,
        note: note,
      );
    }

    test('create() oluşturduğunda isCompleted false olmalı', () {
      final item = createSample();
      expect(item.isCompleted, isFalse);
    });

    test('create() her çağrıda benzersiz id üretmeli', () {
      final a = createSample();
      final b = createSample();
      expect(a.id, isNot(equals(b.id)));
    });

    test('copyWith(isCompleted: true) tamamlandı durumuna geçirmeli', () {
      final item = createSample();
      final completed = item.copyWith(isCompleted: true);
      expect(completed.isCompleted, isTrue);
      expect(completed.id, equals(item.id)); // id değişmemeli
    });

    test('copyWith() değiştirilmeyen alanları korumalı', () {
      final item = createSample(name: 'Ekmek', quantity: 1.0, unit: 'adet');
      final updated = item.copyWith(isCompleted: true);
      expect(updated.name, equals('Ekmek'));
      expect(updated.quantity, equals(1.0));
      expect(updated.unit, equals('adet'));
    });

    test('copyWith(clearNote: true) notu temizlemeli', () {
      final item = createSample(note: 'Tam yağlı');
      final cleared = item.copyWith(clearNote: true);
      expect(cleared.note, isNull);
    });

    test('toJson / fromJson round-trip', () {
      final original = createSample(note: 'Tam yağlı');
      final json = original.toJson();
      final restored = ShoppingItem.fromJson(json);

      expect(restored.id, equals(original.id));
      expect(restored.name, equals(original.name));
      expect(restored.quantity, equals(original.quantity));
      expect(restored.unit, equals(original.unit));
      expect(restored.category, equals(original.category));
      expect(restored.note, equals(original.note));
      expect(restored.isCompleted, equals(original.isCompleted));
    });

    test('fromJson bozuk category değerini other olarak yorumlamalı', () {
      final json = createSample().toJson()..['category'] = 'geçersiz_kategori';
      final item = ShoppingItem.fromJson(json);
      expect(item.category, equals(ItemCategory.other));
    });

    test('== operatörü sadece id karşılaştırmalı', () {
      final item = createSample();
      final copy = item.copyWith(name: 'Farklı Ad');
      expect(item == copy, isTrue);

      final different = createSample();
      expect(item == different, isFalse);
    });
  });
}
