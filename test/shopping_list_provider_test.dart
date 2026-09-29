import 'package:flutter_test/flutter_test.dart';
import 'package:shopping_list_app/models/filter_option.dart';
import 'package:shopping_list_app/models/item_category.dart';
import 'package:shopping_list_app/providers/shopping_list_provider.dart';
import 'fake_repository.dart';

void main() {
  late ShoppingListProvider provider;

  setUp(() async {
    final repo = await createTestRepository();
    provider = ShoppingListProvider(repo);
  });

  // Yardımcı: listeye ürün ekle
  Future<void> addItem(
    String name, {
    double quantity = 1.0,
    String unit = 'adet',
    ItemCategory category = ItemCategory.other,
    String? note,
  }) {
    return provider.addItem(
      name: name,
      quantity: quantity,
      unit: unit,
      category: category,
      note: note,
    );
  }

  group('Ürün ekleme', () {
    test('Yeni ürün listeye eklenmeli', () async {
      await addItem('Süt');
      expect(provider.filteredItems.length, equals(1));
      expect(provider.filteredItems.first.name, equals('Süt'));
    });

    test('Eklenen ürün tamamlanmamış olmalı', () async {
      await addItem('Ekmek');
      expect(provider.filteredItems.first.isCompleted, isFalse);
    });

    test('Birden fazla ürün eklenebilmeli', () async {
      await addItem('A');
      await addItem('B');
      await addItem('C');
      expect(provider.totalCount, equals(3));
    });

    test('totalCount güncellenmeli', () async {
      expect(provider.totalCount, equals(0));
      await addItem('Test');
      expect(provider.totalCount, equals(1));
    });
  });

  group('Ürün tamamlama', () {
    test('toggleItem tamamlandı durumunu değiştirmeli', () async {
      await addItem('Süt');
      final id = provider.filteredItems.first.id;

      await provider.toggleItem(id);
      expect(provider.filteredItems.first.isCompleted, isTrue);

      await provider.toggleItem(id);
      expect(provider.filteredItems.first.isCompleted, isFalse);
    });

    test('completedCount doğru güncellenmeli', () async {
      await addItem('A');
      await addItem('B');
      expect(provider.completedCount, equals(0));
      expect(provider.activeCount, equals(2));

      await provider.toggleItem(provider.filteredItems.first.id);
      expect(provider.completedCount, equals(1));
      expect(provider.activeCount, equals(1));
    });
  });

  group('Ürün silme', () {
    test('removeItem ürünü listeden kaldırmalı', () async {
      await addItem('Elma');
      final id = provider.filteredItems.first.id;

      await provider.removeItem(id);
      expect(provider.totalCount, equals(0));
    });

    test('removeItem silinen ürünü döndürmeli', () async {
      await addItem('Elma');
      final id = provider.filteredItems.first.id;

      final removed = await provider.removeItem(id);
      expect(removed.name, equals('Elma'));
    });

    test('restoreItem silinen ürünü geri eklemeli', () async {
      await addItem('Elma');
      final id = provider.filteredItems.first.id;

      final removed = await provider.removeItem(id);
      expect(provider.totalCount, equals(0));

      await provider.restoreItem(removed);
      expect(provider.totalCount, equals(1));
      expect(provider.filteredItems.first.name, equals('Elma'));
    });
  });

  group('Ürün düzenleme', () {
    test('updateItem mevcut ürünü güncellenmeli', () async {
      await addItem('Eski Ad', quantity: 1.0, unit: 'adet');
      final id = provider.filteredItems.first.id;

      await provider.updateItem(
        id,
        name: 'Yeni Ad',
        quantity: 3.0,
        unit: 'kg',
        category: ItemCategory.fruitVegetable,
      );

      final updated = provider.filteredItems.first;
      expect(updated.name, equals('Yeni Ad'));
      expect(updated.quantity, equals(3.0));
      expect(updated.unit, equals('kg'));
      expect(updated.category, equals(ItemCategory.fruitVegetable));
    });

    test('updateItem id değiştirmemeli', () async {
      await addItem('Test');
      final id = provider.filteredItems.first.id;

      await provider.updateItem(
        id,
        name: 'Değişti',
        quantity: 1.0,
        unit: 'adet',
        category: ItemCategory.other,
      );

      expect(provider.filteredItems.first.id, equals(id));
    });

    test('clearNote ile not temizlenmeli', () async {
      await addItem('Test', note: 'Silinecek');
      final id = provider.filteredItems.first.id;

      await provider.updateItem(
        id,
        name: 'Test',
        quantity: 1.0,
        unit: 'adet',
        category: ItemCategory.other,
        clearNote: true,
      );

      expect(provider.filteredItems.first.note, isNull);
    });
  });

  group('Filtreleme', () {
    setUp(() async {
      await addItem('Süt');
      await addItem('Ekmek');
      await addItem('Elma');
      // Süt'ü tamamla
      await provider.toggleItem(provider.filteredItems.first.id);
    });

    test('FilterOption.all tüm ürünleri göstermeli', () {
      provider.setFilter(FilterOption.all);
      expect(provider.filteredItems.length, equals(3));
    });

    test('FilterOption.active sadece tamamlanmamışları göstermeli', () {
      provider.setFilter(FilterOption.active);
      expect(provider.filteredItems.every((i) => !i.isCompleted), isTrue);
    });

    test('FilterOption.completed sadece tamamlanmışları göstermeli', () {
      provider.setFilter(FilterOption.completed);
      expect(provider.filteredItems.every((i) => i.isCompleted), isTrue);
    });
  });

  group('Arama', () {
    setUp(() async {
      await addItem('Süt');
      await addItem('Sütlaç');
      await addItem('Ekmek');
    });

    test('Boş query tüm ürünleri döndürmeli', () {
      provider.setSearchQuery('');
      expect(provider.filteredItems.length, equals(3));
    });

    test('Arama büyük/küçük harf duyarsız olmalı', () {
      provider.setSearchQuery('süt');
      expect(provider.filteredItems.length, equals(2));

      provider.setSearchQuery('SÜT');
      expect(provider.filteredItems.length, equals(2));
    });

    test('Eşleşme olmayan sorgu boş liste döndürmeli', () {
      provider.setSearchQuery('xyz_olmayan');
      expect(provider.filteredItems.isEmpty, isTrue);
    });

    test('Kısmi eşleşme çalışmalı', () {
      provider.setSearchQuery('ekme');
      expect(provider.filteredItems.length, equals(1));
      expect(provider.filteredItems.first.name, equals('Ekmek'));
    });
  });

  group('clearCompleted', () {
    test('Tüm tamamlananları silmeli', () async {
      await addItem('A');
      await addItem('B');
      await provider.toggleItem(provider.filteredItems.first.id);

      await provider.clearCompleted();
      expect(provider.completedCount, equals(0));
      expect(provider.activeCount, equals(1));
    });
  });

  group('Persistence', () {
    test('Repository saveItems çağrılmalı', () async {
      // SharedPreferences mock kullanılır; veri gerçekten saklanır.
      final repo = await createTestRepository();
      final p1 = ShoppingListProvider(repo);

      await p1.addItem(
        name: 'Kalıcı Ürün',
        quantity: 1.0,
        unit: 'adet',
        category: ItemCategory.other,
      );

      // Aynı repo'dan yeni provider oluştur
      final p2 = ShoppingListProvider(repo);
      expect(p2.filteredItems.length, equals(1));
      expect(p2.filteredItems.first.name, equals('Kalıcı Ürün'));
    });
  });
}
