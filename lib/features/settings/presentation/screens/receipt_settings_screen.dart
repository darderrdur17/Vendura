import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendura/core/theme/app_theme.dart';
import 'package:vendura/core/providers/settings_provider.dart';

class ReceiptSettingsScreen extends ConsumerStatefulWidget {
  const ReceiptSettingsScreen({super.key});

  @override
  ConsumerState<ReceiptSettingsScreen> createState() => _ReceiptSettingsScreenState();
}

class _ReceiptSettingsScreenState extends ConsumerState<ReceiptSettingsScreen> {
  bool _autoPrintEnabled = true;
  bool _printLogo = true;
  bool _printTax = true;
  bool _printTotal = true;
  bool _printFooter = true;
  String _receiptSize = '80mm';
  String _fontSize = 'Medium';
  String _printerType = 'Thermal Printer';
  String _printerName = 'Star TSP100';
  
  final List<String> _receiptSizes = ['58mm', '80mm', 'A4'];
  final List<String> _fontSizes = ['Small', 'Medium', 'Large'];
  final List<String> _printerTypes = ['Thermal Printer', 'Inkjet Printer', 'Laser Printer'];

  final List<Map<String, dynamic>> _receiptTemplates = [
    {
      'name': 'Standard Receipt',
      'description': 'Basic receipt with logo and totals',
      'isDefault': true,
    },
    {
      'name': 'Detailed Receipt',
      'description': 'Receipt with itemized breakdown',
      'isDefault': false,
    },
    {
      'name': 'Compact Receipt',
      'description': 'Minimal receipt for quick printing',
      'isDefault': false,
    },
  ];

  // Receipt content fields
  late TextEditingController _cafeNameController;
  late TextEditingController _sloganController;
  late TextEditingController _footerController;
  bool _showContactInfo = true;

  @override
  void initState() {
    super.initState();
    final receiptSettings = ref.read(receiptSettingsProvider);
    _cafeNameController = TextEditingController(text: receiptSettings['cafeName'] ?? 'Vendura Cafe');
    _sloganController = TextEditingController(text: receiptSettings['slogan'] ?? 'Brewed with Passion');
    _footerController = TextEditingController(text: receiptSettings['footer'] ?? 'Thank you for your business!');
    _showContactInfo = receiptSettings['showContactInfo'] ?? true;
  }

  @override
  void dispose() {
    _cafeNameController.dispose();
    _sloganController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Settings'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _testPrint,
            icon: const Icon(Icons.print),
            tooltip: 'Test Print',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Printer Status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: AppTheme.cardDecoration(elevated: true),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.print,
                        size: 40,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: AppTheme.spacingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Printer Status',
                              style: AppTheme.titleSmall.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              _printerName,
                              style: AppTheme.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        ),
                        child: Text(
                          'Connected',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatusItem('Paper', 'Available', Colors.green),
                      ),
                      Expanded(
                        child: _buildStatusItem('Ink', '85%', Colors.blue),
                      ),
                      Expanded(
                        child: _buildStatusItem('Status', 'Ready', Colors.green),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingL),
            
            // Print Settings
            _buildSectionHeader('Print Settings', Icons.settings),
            const SizedBox(height: AppTheme.spacingM),
            
            Container(
              decoration: AppTheme.cardDecoration(elevated: true),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Auto Print'),
                    subtitle: const Text('Automatically print receipts'),
                    value: _autoPrintEnabled,
                    onChanged: (value) {
                      setState(() {
                        _autoPrintEnabled = value;
                      });
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                  
                  const Divider(height: 1),
                  
                  SwitchListTile(
                    title: const Text('Print Logo'),
                    subtitle: const Text('Include logo on receipts'),
                    value: _printLogo,
                    onChanged: (value) {
                      setState(() {
                        _printLogo = value;
                      });
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                  
                  const Divider(height: 1),
                  
                  SwitchListTile(
                    title: const Text('Print Tax'),
                    subtitle: const Text('Include tax information'),
                    value: _printTax,
                    onChanged: (value) {
                      setState(() {
                        _printTax = value;
                      });
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                  
                  const Divider(height: 1),
                  
                  SwitchListTile(
                    title: const Text('Print Total'),
                    subtitle: const Text('Include total amount'),
                    value: _printTotal,
                    onChanged: (value) {
                      setState(() {
                        _printTotal = value;
                      });
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                  
                  const Divider(height: 1),
                  
                  SwitchListTile(
                    title: const Text('Print Footer'),
                    subtitle: const Text('Include footer message'),
                    value: _printFooter,
                    onChanged: (value) {
                      setState(() {
                        _printFooter = value;
                      });
                    },
                    activeColor: AppTheme.primaryColor,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingL),
            
            // Printer Configuration
            _buildSectionHeader('Printer Configuration', Icons.print),
            const SizedBox(height: AppTheme.spacingM),
            
            Container(
              decoration: AppTheme.cardDecoration(elevated: true),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Receipt Size'),
                    subtitle: Text(_receiptSize),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showSizeDialog(),
                  ),
                  
                  const Divider(height: 1),
                  
                  ListTile(
                    title: const Text('Font Size'),
                    subtitle: Text(_fontSize),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showFontDialog(),
                  ),
                  
                  const Divider(height: 1),
                  
                  ListTile(
                    title: const Text('Printer Type'),
                    subtitle: Text(_printerType),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showPrinterDialog(),
                  ),
                  
                  const Divider(height: 1),
                  
                  ListTile(
                    title: const Text('Select Printer'),
                    subtitle: Text(_printerName),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: _selectPrinter,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingL),
            
            // Receipt Templates
            _buildSectionHeader('Receipt Templates', Icons.receipt),
            const SizedBox(height: AppTheme.spacingM),
            
            ..._receiptTemplates.map((template) => _buildTemplateCard(template)).toList(),
            
            const SizedBox(height: AppTheme.spacingL),
            
            // Receipt Content
            _buildSectionHeader('Receipt Content', Icons.edit),
            const SizedBox(height: AppTheme.spacingM),
            
            Container(
              decoration: AppTheme.cardDecoration(elevated: true),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.business, color: Colors.blue),
                    title: const Text('Business Information'),
                    subtitle: const Text('Edit business details'),
                    onTap: _editBusinessInfo,
                  ),
                  
                  const Divider(height: 1),
                  
                  ListTile(
                    leading: const Icon(Icons.message, color: Colors.green),
                    title: const Text('Footer Message'),
                    subtitle: const Text('Custom footer text'),
                    onTap: _editFooterMessage,
                  ),
                  
                  const Divider(height: 1),
                  
                  ListTile(
                    leading: const Icon(Icons.qr_code, color: Colors.purple),
                    title: const Text('QR Code'),
                    subtitle: const Text('Include QR code on receipts'),
                    onTap: _configureQRCode,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingL),
            
            // Test Print
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _testPrint,
                icon: const Icon(Icons.print),
                label: const Text('Test Print'),
                style: AppTheme.primaryButtonStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor),
        const SizedBox(width: AppTheme.spacingS),
        Text(
          title,
          style: AppTheme.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateCard(Map<String, dynamic> template) {
    final name = template['name'] as String;
    final description = template['description'] as String;
    final isDefault = template['isDefault'] as bool;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      decoration: AppTheme.cardDecoration(elevated: true),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppTheme.spacingS),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: Icon(
            Icons.receipt,
            color: AppTheme.primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          name,
          style: AppTheme.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Text(
                  'Default',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: AppTheme.spacingS),
            const Icon(Icons.arrow_forward_ios),
          ],
        ),
        onTap: () => _editTemplate(template),
      ),
    );
  }

  void _showSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Receipt Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _receiptSizes.map((size) {
            return RadioListTile<String>(
              title: Text(size),
              value: size,
              groupValue: _receiptSize,
              onChanged: (value) {
                setState(() {
                  _receiptSize = value!;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showFontDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Font Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _fontSizes.map((size) {
            return RadioListTile<String>(
              title: Text(size),
              value: size,
              groupValue: _fontSize,
              onChanged: (value) {
                setState(() {
                  _fontSize = value!;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showPrinterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Printer Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _printerTypes.map((type) {
            return RadioListTile<String>(
              title: Text(type),
              value: type,
              groupValue: _printerType,
              onChanged: (value) {
                setState(() {
                  _printerType = value!;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _selectPrinter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Printer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Star TSP100'),
              subtitle: const Text('Thermal Printer'),
              leading: const Icon(Icons.print),
              onTap: () {
                setState(() {
                  _printerName = 'Star TSP100';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Epson TM-T88VI'),
              subtitle: const Text('Thermal Printer'),
              leading: const Icon(Icons.print),
              onTap: () {
                setState(() {
                  _printerName = 'Epson TM-T88VI';
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _editTemplate(Map<String, dynamic> template) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editing template: ${template['name']}'),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _editBusinessInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Business Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _cafeNameController,
              decoration: const InputDecoration(
                labelText: 'Cafe Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            TextField(
              controller: _sloganController,
              decoration: const InputDecoration(
                labelText: 'Slogan',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppTheme.spacingM),
            SwitchListTile(
              title: const Text('Show Contact Info'),
              value: _showContactInfo,
              onChanged: (value) {
                setState(() {
                  _showContactInfo = value;
                });
              },
              activeColor: AppTheme.primaryColor,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(settingsProvider.notifier).updateReceiptSettings({
                ...ref.read(receiptSettingsProvider),
                'cafeName': _cafeNameController.text,
                'slogan': _sloganController.text,
                'showContactInfo': _showContactInfo,
                'footer': _footerController.text,
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Business information updated!'),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            style: AppTheme.primaryButtonStyle,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editFooterMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Footer Message'),
        content: TextField(
          controller: _footerController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Footer Text',
            border: OutlineInputBorder(),
            hintText: 'Thank you for your business!',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(settingsProvider.notifier).updateReceiptSettings({
                ...ref.read(receiptSettingsProvider),
                'cafeName': _cafeNameController.text,
                'slogan': _sloganController.text,
                'showContactInfo': _showContactInfo,
                'footer': _footerController.text,
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Footer message updated!'),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            style: AppTheme.primaryButtonStyle,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _configureQRCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Include QR Code'),
              subtitle: const Text('Add QR code to receipts'),
              value: true,
              onChanged: (value) {},
              activeColor: AppTheme.primaryColor,
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'QR Code Content',
                border: OutlineInputBorder(),
                hintText: 'https://vendura.com/receipt',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('QR code settings updated!'),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            style: AppTheme.primaryButtonStyle,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _testPrint() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Printing test receipt...'),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }
} 