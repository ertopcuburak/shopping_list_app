import 'package:flutter/foundation.dart';
import '../models/filter_option.dart';
import '../models/item_category.dart';
import '../models/shopping_item.dart';
import '../repositories/shopping_repository.dart';

/// Alışveriş listesinin tüm state'ini ve business logic'ini yönetir.
///
/// UI katmanı yalnızca bu provider üzerinden state'i okur ve değiştirir.
class ShoppingListProvider extends ChangeNotifier {
  ShoppingListProvider(this._repository) {
    _items = _repository.loadItems();
  }

  final ShoppingRepository _repository;

  List<ShoppingItem> _items = [];
  FilterOption _filter = FilterOption.all;
  String _searchQuery = '';

  // ── Public getters ────────────────────────────────────────────────────────

  FilterOption get filter => _filter;
  String get searchQuery => _searchQuery;

  int get totalCount => _items.length;
  int get completedCount => _items.where((i) => i.isCompleted).count;
  int get activeCount => _items.where((i) => !i.isCompleted).count;

  /// Filtre ve aramaya göre görüntülenen ürün listesi.
  List<ShoppingItem> get filteredItems {
    Iterable<ShoppingItem> result = _items;

    // Filtre uygula
    switch (_filter) {
      case FilterOption.active:
        result = result.where((i) => !i.isCompleted);
      case FilterOption.completed:
        result = result.where((i) => i.isCompleted);
      case FilterOption.all:
        break;
    }

    // Arama uygula
    final query = _searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where(
        (i) => i.name.toLowerCase().contains(query),
      );
    }

    return result.toList();
  }

  // ── Mutators ──────────────────────────────────────────────────────────────

  /// Yeni bir ürün ekler.
  Future<void> addItem({
    required String name,
    required double quantity,
    required String unit,
    required ItemCategory category,
    String? note,
  }) async {
    final item = ShoppingItem.create(
      name: name,
      quantity: quantity,
      unit: unit,
      category: category,
      note: note,
    );
    _items = [..._items, item];
    await _persist();
  }

  /// Mevcut bir ürünü düzenler.
  Future<void> updateItem(
    String id, {
    required String name,
    required double quantity,
    required String unit,
    required ItemCategory category,
    String? note,
    bool clearNote = false,
  }) async {
    _items = _items.map((item) {
      if (item.id == id) {
        return item.copyWith(
          name: name,
          quantity: quantity,
          unit: unit,
          category: category,
          note: note,
          clearNote: clearNote,
        );
      }
      return item;
    }).toList();
    await _persist();
  }

  /// Ürünün tamamlandı/tamamlanmadı durumunu değiştirir.
  Future<void> toggleItem(String id) async {
    _items = _items.map((item) {
      if (item.id == id) {
        return item.copyWith(isCompleted: !item.isCompleted);
      }
      return item;
    }).toList();
    await _persist();
  }

  /// Ürünü listeden kaldırır; geri alma için orijinal ürünü döner.
  Future<ShoppingItem> removeItem(String id) async {
    final removed = _items.firstWhere((i) => i.id == id);
    _items = _items.where((i) => i.id != id).toList();
    await _persist();
    return removed;
  }

  /// Silinen bir ürünü orijinal konumuna geri ekler (Undo).
  Future<void> restoreItem(ShoppingItem item) async {
    // createdAt'e göre sıralı konuma ekle
    final insertIndex = _items.indexWhere(
      (i) => i.createdAt.isAfter(item.createdAt),
    );
    if (insertIndex == -1) {
      _items = [..._items, item];
    } else {
      final mutable = List<ShoppingItem>.from(_items);
      mutable.insert(insertIndex, item);
      _items = mutable;
    }
    await _persist();
  }

  /// Tüm tamamlanan ürünleri listeden temizler.
  Future<void> clearCompleted() async {
    _items = _items.where((i) => !i.isCompleted).toList();
    await _persist();
  }

  /// Filtre seçeneğini değiştirir.
  void setFilter(FilterOption filter) {
    if (_filter == filter) return;
    _filter = filter;
    notifyListeners();
  }

  /// Arama sorgusunu günceller.
  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }

  // ── Private ───────────────────────────────────────────────────────────────

  Future<void> _persist() async {
    notifyListeners();
    await _repository.saveItems(_items);
  }
}

extension _IterableCount<T> on Iterable<T> {
  int get count => fold(0, (sum, _) => sum + 1);
}
