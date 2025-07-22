import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendura/core/theme/app_theme.dart';
import 'package:vendura/core/providers/inventory_provider.dart';

class AddOnDialog extends ConsumerStatefulWidget {
  final String itemId;
  const AddOnDialog({super.key, required this.itemId});

  @override
  ConsumerState<AddOnDialog> createState() => _AddOnDialogState();
}

class _AddOnDialogState extends ConsumerState<AddOnDialog> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Add-On'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _priceCtrl,
            decoration: const InputDecoration(labelText: 'Price'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            final name = _nameCtrl.text.trim();
            final price = double.tryParse(_priceCtrl.text) ?? 0.0;
            if (name.isEmpty) return;
            await ref.read(inventoryProvider.notifier).addAddOn(widget.itemId, {
              'id': DateTime.now().millisecondsSinceEpoch.toString(),
              'name': name,
              'price': price,
              'isAvailable': true,
            });
            if (mounted) Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
} 