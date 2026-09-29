/// Ana ekrandaki filtreleme seçenekleri.
enum FilterOption {
  all,
  active,
  completed;

  String get label {
    switch (this) {
      case FilterOption.all:
        return 'Tümü';
      case FilterOption.active:
        return 'Alınacaklar';
      case FilterOption.completed:
        return 'Tamamlananlar';
    }
  }
}
