import 'package:flutter/material.dart';
import '../models/filter_option.dart';

/// Tümü / Alınacaklar / Tamamlananlar filtre çubuğu.
class FilterChipBar extends StatelessWidget {
  const FilterChipBar({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
    required this.totalCount,
    required this.activeCount,
    required this.completedCount,
  });

  final FilterOption currentFilter;
  final ValueChanged<FilterOption> onFilterChanged;
  final int totalCount;
  final int activeCount;
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildChip(context, FilterOption.all, totalCount),
          const SizedBox(width: 8),
          _buildChip(context, FilterOption.active, activeCount),
          const SizedBox(width: 8),
          _buildChip(context, FilterOption.completed, completedCount),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, FilterOption option, int count) {
    final isSelected = currentFilter == option;
    return FilterChip(
      label: Text('${option.label} ($count)'),
      selected: isSelected,
      onSelected: (_) => onFilterChanged(option),
      showCheckmark: false,
    );
  }
}
