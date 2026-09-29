import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shopping_item.dart';

/// [ShoppingItem] listesini [SharedPreferences] üzerinde saklar ve okur.
///
/// Persistence katmanı; business logic içermez.
class ShoppingRepository {
  static const String _storageKey = 'shopping_items';

  final SharedPreferences _prefs;

  ShoppingRepository(this._prefs);

  /// Tüm ürünleri SharedPreferences'tan yükler.
  List<ShoppingItem> loadItems() {
    final raw = _prefs.getString(_storageKey);
    if (raw == null) return [];

    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => ShoppingItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Bozuk veri varsa boş liste dön, veriyi sil.
      _prefs.remove(_storageKey);
      return [];
    }
  }

  /// Tüm ürün listesini SharedPreferences'a kaydeder.
  Future<void> saveItems(List<ShoppingItem> items) async {
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await _prefs.setString(_storageKey, encoded);
  }
}
