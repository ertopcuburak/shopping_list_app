import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopping_list_app/models/shopping_item.dart';
import 'package:shopping_list_app/repositories/shopping_repository.dart';

/// Test ortamında kullanılmak üzere, bellekte çalışan repository.
///
/// SharedPreferences.setMockInitialValues ile mock prefs inject edilir.
class TestShoppingRepository {
  final List<ShoppingItem> _items;

  TestShoppingRepository([List<ShoppingItem>? initialItems])
      : _items = List.from(initialItems ?? []);

  List<ShoppingItem> get items => List.unmodifiable(_items);

  List<ShoppingItem> loadItems() => List.from(_items);

  Future<void> saveItems(List<ShoppingItem> items) async {
    _items
      ..clear()
      ..addAll(items);
  }
}

/// [ShoppingRepository]'yi test için mock SharedPreferences ile oluşturur.
Future<ShoppingRepository> createTestRepository([
  List<ShoppingItem> initialItems = const [],
]) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final repo = ShoppingRepository(prefs);
  if (initialItems.isNotEmpty) {
    await repo.saveItems(initialItems);
  }
  return repo;
}
