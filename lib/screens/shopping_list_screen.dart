import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/shopping_item.dart';
import '../providers/shopping_list_provider.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/filter_chip_bar.dart';
import '../widgets/shopping_item_tile.dart';
import 'add_edit_item_screen.dart';

/// Uygulamanın ana ekranı; alışveriş listesini gösterir.
class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() => setState(() => _isSearching = true);

  void _stopSearch() {
    setState(() => _isSearching = false);
    _searchController.clear();
    context.read<ShoppingListProvider>().setSearchQuery('');
  }

  Future<void> _openAddItemScreen() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => const AddEditItemScreen()),
    );
  }

  Future<void> _openEditItemScreen(ShoppingItem item) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => AddEditItemScreen(existingItem: item)),
    );
  }

  Future<void> _onDismissed(
    BuildContext context,
    ShoppingListProvider provider,
    ShoppingItem item,
  ) async {
    final removed = await provider.removeItem(item.id);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${removed.name} silindi'),
        action: SnackBarAction(
          label: 'Geri Al',
          onPressed: () => provider.restoreItem(removed),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddItemScreen,
        icon: const Icon(Icons.add),
        label: const Text('Ürün Ekle'),
        heroTag: 'addItemFab',
      ),
    );
  }

  AppBar _buildAppBar() {
    if (_isSearching) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _stopSearch,
          tooltip: 'Aramayı kapat',
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Ürün ara...',
            border: InputBorder.none,
          ),
          onChanged: (q) =>
              context.read<ShoppingListProvider>().setSearchQuery(q),
        ),
      );
    }

    return AppBar(
      title: const Text('Alışveriş Listem'),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: _startSearch,
          tooltip: 'Ara',
        ),
        _ClearCompletedButton(),
      ],
    );
  }

  Widget _buildBody() {
    return Consumer<ShoppingListProvider>(
      builder: (context, provider, _) {
        final items = provider.filteredItems;

        return Column(
          children: [
            _SummaryBanner(
              totalCount: provider.totalCount,
              completedCount: provider.completedCount,
            ),
            FilterChipBar(
              currentFilter: provider.filter,
              onFilterChanged: provider.setFilter,
              totalCount: provider.totalCount,
              activeCount: provider.activeCount,
              completedCount: provider.completedCount,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: items.isEmpty
                  ? _buildEmptyState(provider)
                  : _buildList(context, provider, items),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(ShoppingListProvider provider) {
    if (provider.totalCount == 0) {
      return EmptyStateView(
        icon: Icons.shopping_cart_outlined,
        message: 'Alışveriş listeniz boş',
        subtitle: 'Yeni ürün eklemek için aşağıdaki butona dokunun.',
        actionLabel: 'İlk Ürünü Ekle',
        onAction: _openAddItemScreen,
      );
    }

    // Filtre veya arama sonucu boş
    return EmptyStateView(
      icon: Icons.filter_list_off,
      message: 'Sonuç bulunamadı',
      subtitle: 'Farklı bir filtre veya arama terimi deneyin.',
    );
  }

  Widget _buildList(
    BuildContext context,
    ShoppingListProvider provider,
    List<ShoppingItem> items,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ShoppingItemTile(
          key: ValueKey(item.id),
          item: item,
          onToggle: () => provider.toggleItem(item.id),
          onDismissed: () => _onDismissed(context, provider, item),
          onEdit: () => _openEditItemScreen(item),
        );
      },
    );
  }
}

// ── Alt yardımcı widget'lar ───────────────────────────────────────────────────

class _SummaryBanner extends StatelessWidget {
  const _SummaryBanner({
    required this.totalCount,
    required this.completedCount,
  });

  final int totalCount;
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    if (totalCount == 0) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.checklist,
            color: colorScheme.onPrimaryContainer,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Toplam $totalCount ürün',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '$completedCount / $totalCount tamamlandı',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClearCompletedButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ShoppingListProvider>(
      builder: (context, provider, _) {
        if (provider.completedCount == 0) return const SizedBox.shrink();
        return IconButton(
          icon: const Icon(Icons.playlist_remove),
          tooltip: 'Tamamlananları temizle',
          onPressed: () => _confirmClear(context, provider),
        );
      },
    );
  }

  Future<void> _confirmClear(
    BuildContext context,
    ShoppingListProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tamamlananları Temizle'),
        content: Text(
          '${provider.completedCount} tamamlanan ürün listeden kaldırılacak. '
          'Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Temizle'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.clearCompleted();
    }
  }
}
