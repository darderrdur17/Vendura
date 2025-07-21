import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendura/core/theme/app_theme.dart';

class PaymentMethodsScreen extends ConsumerStatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  ConsumerState<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends ConsumerState<PaymentMethodsScreen> {
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'cash',
      'name': 'Cash',
      'description': 'Physical cash payments',
      'icon': Icons.money,
      'isEnabled': true,
      'isDefault': false,
      'settings': {
        'acceptChange': true,
        'roundToNearest': 0.25,
      },
    },
    {
      'id': 'card',
      'name': 'Credit/Debit Card',
      'description': 'Card payments via terminal',
      'icon': Icons.credit_card,
      'isEnabled': true,
      'isDefault': true,
      'settings': {
        'requireSignature': false,
        'contactlessEnabled': true,
        'chipCardEnabled': true,
      },
    },
    {
      'id': 'mobile',
      'name': 'Mobile Payments',
      'description': 'Apple Pay, Google Pay, etc.',
      'icon': Icons.phone_android,
      'isEnabled': true,
      'isDefault': false,
      'settings': {
        'applePayEnabled': true,
        'googlePayEnabled': true,
        'samsungPayEnabled': false,
      },
    },
    {
      'id': 'split',
      'name': 'Split Payment',
      'description': 'Multiple payment methods',
      'icon': Icons.account_balance_wallet,
      'isEnabled': true,
      'isDefault': false,
      'settings': {
        'maxSplits': 4,
        'allowUnevenSplit': true,
      },
    },
    {
      'id': 'gift',
      'name': 'Gift Cards',
      'description': 'Gift card redemption',
      'icon': Icons.card_giftcard,
      'isEnabled': false,
      'isDefault': false,
      'settings': {
        'acceptPartialPayment': true,
        'allowReload': false,
      },
    },
    {
      'id': 'online',
      'name': 'Online Orders',
      'description': 'Pre-paid online orders',
      'icon': Icons.shopping_cart,
      'isEnabled': true,
      'isDefault': false,
      'settings': {
        'requirePrePayment': true,
        'allowTipAdjustment': true,
      },
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _addPaymentMethod,
            icon: const Icon(Icons.add),
            tooltip: 'Add Payment Method',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Info
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Configuration',
                      style: AppTheme.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      'Configure which payment methods are available to customers. You can enable/disable methods and set default options.',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Payment Methods List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              itemCount: _paymentMethods.length,
              itemBuilder: (context, index) {
                final method = _paymentMethods[index];
                return _buildPaymentMethodCard(method);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> method) {
    final name = method['name'] as String;
    final description = method['description'] as String;
    final icon = method['icon'] as IconData;
    final isEnabled = method['isEnabled'] as bool;
    final isDefault = method['isDefault'] as bool;
    final id = method['id'] as String;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      decoration: AppTheme.cardDecoration(elevated: true),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingS),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Icon(
                    icon,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: AppTheme.spacingM),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: AppTheme.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                              ),
                              child: Text(
                                'DEFAULT',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Text(
                        description,
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                Switch(
                  value: isEnabled,
                  onChanged: (value) => _togglePaymentMethod(id, value),
                  activeColor: AppTheme.primaryColor,
                ),
              ],
            ),
            
            if (isEnabled) ...[
              const SizedBox(height: AppTheme.spacingM),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _configurePaymentMethod(method),
                      icon: const Icon(Icons.settings, size: 16),
                      label: const Text('Configure'),
                      style: AppTheme.secondaryButtonStyle,
                    ),
                  ),
                  
                  const SizedBox(width: AppTheme.spacingS),
                  
                  if (!isDefault)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _setAsDefault(id),
                        icon: const Icon(Icons.star, size: 16),
                        label: const Text('Set Default'),
                        style: AppTheme.secondaryButtonStyle,
                      ),
                    ),
                  
                  if (isDefault)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _removeDefault(id),
                        icon: const Icon(Icons.star_border, size: 16),
                        label: const Text('Remove Default'),
                        style: AppTheme.secondaryButtonStyle,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _togglePaymentMethod(String id, bool enabled) {
    setState(() {
      final method = _paymentMethods.firstWhere((m) => m['id'] == id);
      method['isEnabled'] = enabled;
      
      // If disabling default method, remove default status
      if (!enabled && method['isDefault'] == true) {
        method['isDefault'] = false;
      }
    });
    
    final methodName = _paymentMethods.firstWhere((m) => m['id'] == id)['name'];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$methodName ${enabled ? 'enabled' : 'disabled'}'),
        backgroundColor: enabled ? AppTheme.successGreen : AppTheme.warningOrange,
      ),
    );
  }

  void _setAsDefault(String id) {
    setState(() {
      // Remove default from all methods
      for (final method in _paymentMethods) {
        method['isDefault'] = false;
      }
      
      // Set new default
      final method = _paymentMethods.firstWhere((m) => m['id'] == id);
      method['isDefault'] = true;
    });
    
    final method = _paymentMethods.firstWhere((m) => m['id'] == id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${method['name']} set as default payment method'),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }

  void _removeDefault(String id) {
    setState(() {
      final method = _paymentMethods.firstWhere((m) => m['id'] == id);
      method['isDefault'] = false;
    });
    
    final method = _paymentMethods.firstWhere((m) => m['id'] == id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${method['name']} removed as default payment method'),
        backgroundColor: AppTheme.warningOrange,
      ),
    );
  }

  void _configurePaymentMethod(Map<String, dynamic> method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Configure ${method['name']}'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings for ${method['name']}',
                style: AppTheme.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              
              // Dynamic settings based on payment method
              ..._buildPaymentMethodSettings(method),
            ],
          ),
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
                  content: Text('${method['name']} settings saved'),
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

  List<Widget> _buildPaymentMethodSettings(Map<String, dynamic> method) {
    final settings = method['settings'] as Map<String, dynamic>;
    final widgets = <Widget>[];
    
    settings.forEach((key, value) {
      if (value is bool) {
        widgets.add(
          SwitchListTile(
            title: Text(_formatSettingName(key)),
            subtitle: Text(_getSettingDescription(key)),
            value: value,
            onChanged: (newValue) {
              setState(() {
                settings[key] = newValue;
              });
            },
            activeColor: AppTheme.primaryColor,
          ),
        );
      } else if (value is num) {
        widgets.add(
          ListTile(
            title: Text(_formatSettingName(key)),
            subtitle: Text('Current: $value'),
            trailing: IconButton(
              onPressed: () => _editNumericSetting(settings, key, value),
              icon: const Icon(Icons.edit),
            ),
          ),
        );
      }
    });
    
    return widgets;
  }

  String _formatSettingName(String key) {
    final formatted = key.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(1)?.toLowerCase()}',
    );
    return formatted[0].toUpperCase() + formatted.substring(1);
  }

  String _getSettingDescription(String key) {
    switch (key) {
      case 'acceptChange':
        return 'Allow cash payments with change';
      case 'roundToNearest':
        return 'Round cash payments to nearest amount';
      case 'requireSignature':
        return 'Require customer signature for card payments';
      case 'contactlessEnabled':
        return 'Enable contactless card payments';
      case 'chipCardEnabled':
        return 'Enable chip card payments';
      case 'applePayEnabled':
        return 'Accept Apple Pay payments';
      case 'googlePayEnabled':
        return 'Accept Google Pay payments';
      case 'samsungPayEnabled':
        return 'Accept Samsung Pay payments';
      case 'maxSplits':
        return 'Maximum number of payment splits';
      case 'allowUnevenSplit':
        return 'Allow uneven payment splits';
      case 'acceptPartialPayment':
        return 'Allow partial gift card payments';
      case 'allowReload':
        return 'Allow gift card reloading';
      case 'requirePrePayment':
        return 'Require payment before order completion';
      case 'allowTipAdjustment':
        return 'Allow tip adjustment after payment';
      default:
        return 'Configure this setting';
    }
  }

  void _editNumericSetting(Map<String, dynamic> settings, String key, num currentValue) {
    final controller = TextEditingController(text: currentValue.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${_formatSettingName(key)}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: AppTheme.searchInputDecoration(
            hintText: _formatSettingName(key),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newValue = num.tryParse(controller.text);
              if (newValue != null) {
                setState(() {
                  settings[key] = newValue;
                });
              }
              Navigator.pop(context);
            },
            style: AppTheme.primaryButtonStyle,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _addPaymentMethod() {
    // TODO: Implement add payment method
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Add payment method functionality coming soon'),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }
} 