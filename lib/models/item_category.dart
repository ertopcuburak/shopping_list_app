/// Alışveriş ürünlerinin kategorilerini tanımlar.
enum ItemCategory {
  fruitVegetable,
  dairy,
  meatFish,
  bakery,
  beverage,
  breakfast,
  snack,
  cleaning,
  personalCare,
  other;

  /// Kullanıcıya gösterilecek Türkçe etiket.
  String get label {
    switch (this) {
      case ItemCategory.fruitVegetable:
        return 'Meyve & Sebze';
      case ItemCategory.dairy:
        return 'Süt Ürünleri';
      case ItemCategory.meatFish:
        return 'Et & Balık';
      case ItemCategory.bakery:
        return 'Fırın';
      case ItemCategory.beverage:
        return 'İçecek';
      case ItemCategory.breakfast:
        return 'Kahvaltılık';
      case ItemCategory.snack:
        return 'Atıştırmalık';
      case ItemCategory.cleaning:
        return 'Temizlik';
      case ItemCategory.personalCare:
        return 'Kişisel Bakım';
      case ItemCategory.other:
        return 'Diğer';
    }
  }

  /// Kategoriyi temsil eden ikon.
  String get emoji {
    switch (this) {
      case ItemCategory.fruitVegetable:
        return '🥦';
      case ItemCategory.dairy:
        return '🥛';
      case ItemCategory.meatFish:
        return '🥩';
      case ItemCategory.bakery:
        return '🍞';
      case ItemCategory.beverage:
        return '🥤';
      case ItemCategory.breakfast:
        return '🍳';
      case ItemCategory.snack:
        return '🍿';
      case ItemCategory.cleaning:
        return '🧹';
      case ItemCategory.personalCare:
        return '🧴';
      case ItemCategory.other:
        return '📦';
    }
  }

  /// JSON serialize için string key.
  String get key => name;

  /// JSON deserialize için string key'den enum değeri.
  static ItemCategory fromKey(String key) {
    return ItemCategory.values.firstWhere(
      (e) => e.name == key,
      orElse: () => ItemCategory.other,
    );
  }
}
