import 'package:flutter/material.dart';
import '../../models/shopping_item.dart';

/// Listedeki tek bir alışveriş ürününü gösterir.
///
/// Dokunmak tamamlandı durumunu değiştirir.
/// Sola kaydırmak silme işlemini başlatır.
class ShoppingItemTile extends StatelessWidget {
  const ShoppingItemTile({
    super.key,
    required this.item,
    required this.onToggle,
    required this.onDismissed,
    required this.onEdit,
  });

  final ShoppingItem item;
  final VoidCallback onToggle;
  final VoidCallback onDismissed;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(colorScheme),
      confirmDismiss: (_) async => true,
      onDismissed: (_) => onDismissed(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: InkWell(
          onTap: onToggle,
          onLongPress: onEdit,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                _CategoryBadge(item: item),
                const SizedBox(width: 12),
                Expanded(child: _ItemDetails(item: item)),
                _CompletionIndicator(
                  isCompleted: item.isCompleted,
                  onToggle: onToggle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: Icon(
        Icons.delete_outline,
        color: colorScheme.onErrorContainer,
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.item});
  final ShoppingItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: item.isCompleted
            ? colorScheme.surfaceContainerHighest
            : colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          item.category.emoji,
          style: TextStyle(
            fontSize: 22,
            color: item.isCompleted ? colorScheme.outline : null,
          ),
        ),
      ),
    );
  }
}

class _ItemDetails extends StatelessWidget {
  const _ItemDetails({required this.item});
  final ShoppingItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          style: textTheme.titleSmall?.copyWith(
            decoration: item.isCompleted ? TextDecoration.lineThrough : null,
            color: item.isCompleted ? colorScheme.outline : null,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${_formatQuantity(item.quantity)} ${item.unit} · ${item.category.label}',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.outline,
            decoration: item.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        if (item.note != null && item.note!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            item.note!,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.outline,
              fontStyle: FontStyle.italic,
              decoration:
                  item.isCompleted ? TextDecoration.lineThrough : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  String _formatQuantity(double qty) {
    if (qty == qty.truncateToDouble()) {
      return qty.toInt().toString();
    }
    return qty.toString();
  }
}

class _CompletionIndicator extends StatelessWidget {
  const _CompletionIndicator({
    required this.isCompleted,
    required this.onToggle,
  });

  final bool isCompleted;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton(
      onPressed: onToggle,
      icon: Icon(
        isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
        color: isCompleted ? colorScheme.primary : colorScheme.outline,
      ),
      tooltip: isCompleted ? 'Tamamlanmadı olarak işaretle' : 'Tamamlandı olarak işaretle',
    );
  }
}
