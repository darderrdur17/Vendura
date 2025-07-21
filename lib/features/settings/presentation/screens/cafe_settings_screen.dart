import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendura/core/theme/app_theme.dart';

class CafeSettingsScreen extends ConsumerStatefulWidget {
  const CafeSettingsScreen({super.key});

  @override
  ConsumerState<CafeSettingsScreen> createState() => _CafeSettingsScreenState();
}

class _CafeSettingsScreenState extends ConsumerState<CafeSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cafeNameController = TextEditingController(text: 'Vendura Cafe');
  final _addressController = TextEditingController(text: '123 Coffee Street, Downtown');
  final _phoneController = TextEditingController(text: '+1 (555) 123-4567');
  final _emailController = TextEditingController(text: 'info@vendura.com');
  final _websiteController = TextEditingController(text: 'www.vendura.com');
  final _taxRateController = TextEditingController(text: '8.5');
  final _currencyController = TextEditingController(text: 'USD');
  
  String _selectedTimezone = 'America/New_York';
  bool _isOpen = true;
  TimeOfDay _openTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _closeTime = const TimeOfDay(hour: 21, minute: 0);

  List<String> get timezones => [
    'America/New_York',
    'America/Chicago',
    'America/Denver',
    'America/Los_Angeles',
    'Europe/London',
    'Europe/Paris',
    'Asia/Tokyo',
    'Australia/Sydney',
  ];

  @override
  void dispose() {
    _cafeNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _taxRateController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cafe Settings'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _saveSettings,
            icon: const Icon(Icons.save),
            tooltip: 'Save Settings',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Section
              _buildSectionHeader('Basic Information', Icons.store),
              const SizedBox(height: AppTheme.spacingM),
              
              TextFormField(
                controller: _cafeNameController,
                decoration: AppTheme.searchInputDecoration(
                  hintText: 'Cafe Name',
                  prefixIcon: Icons.store,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter cafe name';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppTheme.spacingM),
              
              TextFormField(
                controller: _addressController,
                decoration: AppTheme.searchInputDecoration(
                  hintText: 'Address',
                  prefixIcon: Icons.location_on,
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppTheme.spacingL),
              
              // Contact Information Section
              _buildSectionHeader('Contact Information', Icons.contact_phone),
              const SizedBox(height: AppTheme.spacingM),
              
              TextFormField(
                controller: _phoneController,
                decoration: AppTheme.searchInputDecoration(
                  hintText: 'Phone Number',
                  prefixIcon: Icons.phone,
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppTheme.spacingM),
              
              TextFormField(
                controller: _emailController,
                decoration: AppTheme.searchInputDecoration(
                  hintText: 'Email Address',
                  prefixIcon: Icons.email,
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email address';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppTheme.spacingM),
              
              TextFormField(
                controller: _websiteController,
                decoration: AppTheme.searchInputDecoration(
                  hintText: 'Website',
                  prefixIcon: Icons.language,
                ),
                keyboardType: TextInputType.url,
              ),
              
              const SizedBox(height: AppTheme.spacingL),
              
              // Business Hours Section
              _buildSectionHeader('Business Hours', Icons.access_time),
              const SizedBox(height: AppTheme.spacingM),
              
              SwitchListTile(
                title: const Text('Cafe is Open'),
                subtitle: const Text('Toggle cafe availability'),
                value: _isOpen,
                onChanged: (value) {
                  setState(() {
                    _isOpen = value;
                  });
                },
                activeColor: AppTheme.primaryColor,
              ),
              
              const SizedBox(height: AppTheme.spacingS),
              
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Opening Time'),
                subtitle: Text(_openTime.format(context)),
                onTap: () => _selectTime(context, true),
              ),
              
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Closing Time'),
                subtitle: Text(_closeTime.format(context)),
                onTap: () => _selectTime(context, false),
              ),
              
              const SizedBox(height: AppTheme.spacingL),
              
              // Business Settings Section
              _buildSectionHeader('Business Settings', Icons.business),
              const SizedBox(height: AppTheme.spacingM),
              
              TextFormField(
                controller: _taxRateController,
                decoration: AppTheme.searchInputDecoration(
                  hintText: 'Tax Rate (%)',
                  prefixIcon: Icons.percent,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter tax rate';
                  }
                  final taxRate = double.tryParse(value);
                  if (taxRate == null || taxRate < 0 || taxRate > 100) {
                    return 'Please enter a valid tax rate (0-100)';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppTheme.spacingM),
              
              TextFormField(
                controller: _currencyController,
                decoration: AppTheme.searchInputDecoration(
                  hintText: 'Currency',
                  prefixIcon: Icons.attach_money,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter currency';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: AppTheme.spacingM),
              
              DropdownButtonFormField<String>(
                value: _selectedTimezone,
                decoration: AppTheme.searchInputDecoration(
                  hintText: 'Timezone',
                  prefixIcon: Icons.schedule,
                ),
                items: timezones.map((timezone) {
                  return DropdownMenuItem(
                    value: timezone,
                    child: Text(timezone),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTimezone = value!;
                  });
                },
              ),
              
              const SizedBox(height: AppTheme.spacingXL),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveSettings,
                  style: AppTheme.primaryButtonStyle,
                  child: const Text('Save Settings'),
                ),
              ),
            ],
          ),
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

  Future<void> _selectTime(BuildContext context, bool isOpening) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isOpening ? _openTime : _closeTime,
    );
    
    if (picked != null) {
      setState(() {
        if (isOpening) {
          _openTime = picked;
        } else {
          _closeTime = picked;
        }
      });
    }
  }

  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      // TODO: Save settings to local storage or backend
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Settings saved successfully!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    }
  }
} 