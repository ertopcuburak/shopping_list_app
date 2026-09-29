import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/item_category.dart';
import '../models/shopping_item.dart';
import '../providers/shopping_list_provider.dart';

/// Yeni ürün ekleme veya mevcut ürünü düzenleme ekranı.
///
/// [existingItem] null ise yeni ürün ekleme modu aktifleşir.
class AddEditItemScreen extends StatefulWidget {
  const AddEditItemScreen({super.key, this.existingItem});

  final ShoppingItem? existingItem;

  @override
  State<AddEditItemScreen> createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends State<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _unitController;
  late final TextEditingController _noteController;

  late ItemCategory _selectedCategory;

  bool get _isEditing => widget.existingItem != null;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _nameController = TextEditingController(text: item?.name ?? '');
    _quantityController = TextEditingController(
      text: item != null ? _formatQty(item.quantity) : '1',
    );
    _unitController = TextEditingController(text: item?.unit ?? 'adet');
    _noteController = TextEditingController(text: item?.note ?? '');
    _selectedCategory = item?.category ?? ItemCategory.other;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _formatQty(double qty) {
    if (qty == qty.truncateToDouble()) return qty.toInt().toString();
    return qty.toString();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ShoppingListProvider>();
    final name = _nameController.text.trim();
    final quantity = double.tryParse(_quantityController.text.trim()) ?? 1.0;
    final unit = _unitController.text.trim();
    final note = _noteController.text.trim();
    final category = _selectedCategory;

    if (_isEditing) {
      await provider.updateItem(
        widget.existingItem!.id,
        name: name,
        quantity: quantity,
        unit: unit,
        category: category,
        note: note.isEmpty ? null : note,
        clearNote: note.isEmpty,
      );
    } else {
      await provider.addItem(
        name: name,
        quantity: quantity,
        unit: unit,
        category: category,
        note: note.isEmpty ? null : note,
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Ürünü Düzenle' : 'Yeni Ürün'),
        actions: [
          TextButton(
            onPressed: _submit,
            child: Text(_isEditing ? 'Güncelle' : 'Ekle'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildNameField(),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildQuantityField()),
                const SizedBox(width: 12),
                Expanded(flex: 3, child: _buildUnitField()),
              ],
            ),
            const SizedBox(height: 16),
            _buildCategorySelector(),
            const SizedBox(height: 16),
            _buildNoteField(),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _submit,
              child: Text(
                _isEditing ? 'Güncelle' : 'Listeye Ekle',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(
        labelText: 'Ürün Adı *',
        hintText: 'Örn: Süt, Ekmek, Elma...',
        prefixIcon: Icon(Icons.shopping_bag_outlined),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Ürün adı boş bırakılamaz';
        }
        return null;
      },
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildQuantityField() {
    return TextFormField(
      controller: _quantityController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      decoration: const InputDecoration(
        labelText: 'Miktar',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Miktar girin';
        final parsed = double.tryParse(value.trim());
        if (parsed == null || parsed <= 0) return 'Geçersiz miktar';
        return null;
      },
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildUnitField() {
    return TextFormField(
      controller: _unitController,
      textCapitalization: TextCapitalization.none,
      decoration: const InputDecoration(
        labelText: 'Birim',
        hintText: 'adet, kg, litre...',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Birim girin';
        return null;
      },
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildCategorySelector() {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ItemCategory.values.map((category) {
            final isSelected = _selectedCategory == category;
            return ChoiceChip(
              label: Text('${category.emoji} ${category.label}'),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedCategory = category),
              selectedColor: colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurface,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNoteField() {
    return TextFormField(
      controller: _noteController,
      textCapitalization: TextCapitalization.sentences,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Not (isteğe bağlı)',
        hintText: 'Marka, özellik, hatırlatma...',
        prefixIcon: Icon(Icons.notes_outlined),
        alignLabelWithHint: true,
        border: OutlineInputBorder(),
      ),
      textInputAction: TextInputAction.done,
    );
  }
}
