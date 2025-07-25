import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendura/core/providers/inventory_provider.dart';
import 'package:vendura/core/providers/items_provider.dart';
import 'package:vendura/core/theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:vendura/core/services/image_service.dart';

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
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  final _stockCtrl = TextEditingController(text: '0');
  final _minStockCtrl = TextEditingController(text: '0');
  String _selectedCategory = '';
  bool _available = true;

  @override
  void initState() {
    super.initState();
    if (widget.categories.isNotEmpty) {
      _selectedCategory = widget.categories.first;
      }

  void _createTestImage() {
    print('Creating test image...');
    // For now, just show a success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test image feature - image picker should work now'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl, 
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: widget.categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceCtrl, 
              keyboardType: TextInputType.number, 
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descCtrl, 
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Image picker & preview
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Item Image',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                _selectedImage!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[200],
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: const Icon(Icons.image, size: 30, color: Colors.grey),
                            ),
                      const SizedBox(width: 16),
                                             Expanded(
                         child: Column(
                           children: [
                             ElevatedButton.icon(
                               onPressed: _pickImage,
                               icon: const Icon(Icons.photo_library),
                               label: const Text('Select Image'),
                               style: ElevatedButton.styleFrom(
                                 backgroundColor: AppTheme.primaryColor,
                                 foregroundColor: Colors.white,
                                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                               ),
                             ),
                             const SizedBox(height: 8),
                             ElevatedButton.icon(
                               onPressed: _createTestImage,
                               icon: const Icon(Icons.add_a_photo),
                               label: const Text('Test Image'),
                               style: ElevatedButton.styleFrom(
                                 backgroundColor: Colors.orange,
                                 foregroundColor: Colors.white,
                                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                               ),
                             ),
                           ],
                         ),
                       ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _stockCtrl, 
                  keyboardType: TextInputType.number, 
                  decoration: const InputDecoration(
                    labelText: 'Stock Qty',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _minStockCtrl, 
                  keyboardType: TextInputType.number, 
                  decoration: const InputDecoration(
                    labelText: 'Min Stock',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 16),
            CheckboxListTile(
              value: _available,
              onChanged: (v) => setState(() => _available = v ?? true),
              title: const Text('Available'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            )
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final price = double.tryParse(_priceCtrl.text) ?? 0.0;
    if (name.isEmpty) return;

    String? imagePath;
    if (_selectedImage != null) {
      imagePath = await ImageService.saveImage(_selectedImage!);
    }
    final map = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'category': _selectedCategory,
      'price': price,
      'description': _descCtrl.text.trim(),
      'imageUrl': imagePath,
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

  Future<void> _pickImage() async {
    try {
      print('Starting image picker...');
      
      // Try camera first, then gallery if camera fails
      XFile? picked;
      
      try {
        print('Trying camera source...');
        picked = await _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 800,
          imageQuality: 85,
        );
        print('Camera result: ${picked?.path ?? 'null'}');
      } catch (cameraError) {
        print('Camera failed: $cameraError');
        print('Trying gallery source...');
        picked = await _picker.pickImage(
          source: ImageSource.gallery, 
          maxWidth: 800,
          imageQuality: 85,
        );
        print('Gallery result: ${picked?.path ?? 'null'}');
      }
      
      if (picked != null) {
        print('Image selected: ${picked.path}');
        setState(() {
          _selectedImage = File(picked.path);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image selected successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        print('No image selected');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No image selected'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
} 