import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendura/core/providers/inventory_provider.dart';
import 'package:vendura/core/providers/items_provider.dart';
import 'package:vendura/core/theme/app_theme.dart';

class AddItemDialog extends ConsumerStatefulWidget {
  final List<String> categories;
  const AddItemDialog({super.key, required this.categories});

  @override
  ConsumerState<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends ConsumerState<AddItemDialog> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _stockCtrl = TextEditingController(text: '0');
  final _minStockCtrl = TextEditingController(text: '0');
  String _selectedCategory = 'Coffee';
  bool _available = true;

  @override
  void initState() {
    super.initState();
    if (widget.categories.isNotEmpty) _selectedCategory = widget.categories.first;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: widget.categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 8),
            TextField(controller: _priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price')),
            const SizedBox(height: 8),
            TextField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Description')),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: TextField(controller: _stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stock Qty'))),
              const SizedBox(width: 8),
              Expanded(child: TextField(controller: _minStockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Min Stock'))),
            ]),
            const SizedBox(height: 8),
            CheckboxListTile(
              value: _available,
              onChanged: (v) => setState(() => _available = v ?? true),
              title: const Text('Available'),
              controlAffinity: ListTileControlAffinity.leading,
            )
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _save,
          style: AppTheme.primaryButtonStyle,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final price = double.tryParse(_priceCtrl.text) ?? 0.0;
    if (name.isEmpty) return;
    final map = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'category': _selectedCategory,
      'price': price,
      'description': _descCtrl.text.trim(),
      'stockQuantity': int.tryParse(_stockCtrl.text) ?? 0,
      'minStockLevel': int.tryParse(_minStockCtrl.text) ?? 0,
      'isAvailable': _available,
      'createdAt': DateTime.now().toIso8601String(),
    };
    await ref.read(inventoryProvider.notifier).addItem(map);
    // Refresh settings/menu items provider so new item is visible across app
    ref.read(itemsProvider.notifier).refreshItems();
    if (mounted) Navigator.pop(context);
  }
} 