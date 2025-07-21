import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendura/core/theme/app_theme.dart';

class HelpSupportScreen extends ConsumerStatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  ConsumerState<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends ConsumerState<HelpSupportScreen> {
  final List<Map<String, dynamic>> _faqs = [
    {
      'question': 'How do I create a new order?',
      'answer': 'Tap the "New Order" button on the Orders screen, then select items from the menu and add them to the cart.',
      'category': 'Orders',
    },
    {
      'question': 'How do I process a payment?',
      'answer': 'After creating an order, tap "Payment" and select your preferred payment method. Follow the prompts to complete the transaction.',
      'category': 'Payments',
    },
    {
      'question': 'How do I manage inventory?',
      'answer': 'Go to Settings > Inventory Management to view stock levels, add new items, and adjust quantities.',
      'category': 'Inventory',
    },
    {
      'question': 'How do I print receipts?',
      'answer': 'After completing a payment, tap "Print" on the receipt screen. Make sure your printer is connected and configured.',
      'category': 'Receipts',
    },
    {
      'question': 'How do I process a refund?',
      'answer': 'Go to the Refunds screen, tap "New Refund", select the original receipt, and follow the refund process.',
      'category': 'Refunds',
    },
    {
      'question': 'How do I configure payment methods?',
      'answer': 'Go to Settings > Payment Methods to enable/disable payment options and configure their settings.',
      'category': 'Settings',
    },
    {
      'question': 'How do I backup my data?',
      'answer': 'Go to Settings > Backup & Restore to create automatic backups or manually export your data.',
      'category': 'Data',
    },
    {
      'question': 'How do I sync data across devices?',
      'answer': 'Go to Settings > Sync Settings to configure automatic synchronization with cloud services.',
      'category': 'Sync',
    },
  ];

  final List<Map<String, dynamic>> _contactMethods = [
    {
      'title': 'Email Support',
      'description': 'Get help via email',
      'icon': Icons.email,
      'action': 'support@vendura.com',
      'color': Colors.blue,
    },
    {
      'title': 'Phone Support',
      'description': 'Call us directly',
      'icon': Icons.phone,
      'action': '+1 (555) 123-4567',
      'color': Colors.green,
    },
    {
      'title': 'Live Chat',
      'description': 'Chat with support team',
      'icon': Icons.chat,
      'action': 'Start Chat',
      'color': Colors.orange,
    },
    {
      'title': 'Knowledge Base',
      'description': 'Browse documentation',
      'icon': Icons.article,
      'action': 'View Docs',
      'color': Colors.purple,
    },
  ];

  String _selectedCategory = 'All';

  List<String> get categories => ['All', 'Orders', 'Payments', 'Inventory', 'Receipts', 'Refunds', 'Settings', 'Data', 'Sync'];

  List<Map<String, dynamic>> get filteredFaqs {
    if (_selectedCategory == 'All') return _faqs;
    return _faqs.where((faq) => faq['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showContactDialog,
            icon: const Icon(Icons.contact_support),
            tooltip: 'Contact Support',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: AppTheme.cardDecoration(elevated: true),
              child: Column(
                children: [
                  Icon(
                    Icons.help_outline,
                    size: 60,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Text(
                    'How can we help you?',
                    style: AppTheme.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    'Find answers to common questions or get in touch with our support team.',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingL),
            
            // Contact Methods
            _buildSectionHeader('Get Help', Icons.contact_support),
            const SizedBox(height: AppTheme.spacingM),
            
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppTheme.spacingM,
                mainAxisSpacing: AppTheme.spacingM,
                childAspectRatio: 1.2,
              ),
              itemCount: _contactMethods.length,
              itemBuilder: (context, index) {
                final method = _contactMethods[index];
                return _buildContactCard(method);
              },
            ),
            
            const SizedBox(height: AppTheme.spacingL),
            
            // FAQ Section
            _buildSectionHeader('Frequently Asked Questions', Icons.question_answer),
            const SizedBox(height: AppTheme.spacingM),
            
            // Category Filter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((category) {
                    final isSelected = _selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.only(right: AppTheme.spacingS),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        backgroundColor: Colors.grey[200],
                        selectedColor: AppTheme.primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingM),
            
            // FAQ List
            ...filteredFaqs.map((faq) => _buildFaqCard(faq)).toList(),
            
            const SizedBox(height: AppTheme.spacingL),
            
            // Troubleshooting
            _buildSectionHeader('Troubleshooting', Icons.build),
            const SizedBox(height: AppTheme.spacingM),
            
            _buildTroubleshootingCard(
              'App is slow or unresponsive',
              'Try restarting the app or clearing the cache in Settings > App Details.',
              Icons.speed,
              Colors.orange,
            ),
            
            _buildTroubleshootingCard(
              'Payment not processing',
              'Check your internet connection and payment method settings.',
              Icons.payment,
              Colors.red,
            ),
            
            _buildTroubleshootingCard(
              'Receipt not printing',
              'Verify printer connection and settings in Settings > Receipt Settings.',
              Icons.print,
              Colors.blue,
            ),
            
            _buildTroubleshootingCard(
              'Data not syncing',
              'Check sync settings and internet connection in Settings > Sync Settings.',
              Icons.sync,
              Colors.green,
            ),
            
            const SizedBox(height: AppTheme.spacingXL),
            
            // Feedback Section
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _submitFeedback(context),
                icon: const Icon(Icons.feedback),
                label: const Text('Submit Feedback'),
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

  Widget _buildContactCard(Map<String, dynamic> method) {
    return Container(
      decoration: AppTheme.cardDecoration(elevated: true),
      child: InkWell(
        onTap: () => _handleContactMethod(method),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: method['color'].withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  method['icon'],
                  color: method['color'],
                  size: 24,
                ),
              ),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                method['title'],
                style: AppTheme.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                method['description'],
                style: AppTheme.bodySmall.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqCard(Map<String, dynamic> faq) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      decoration: AppTheme.cardDecoration(elevated: true),
      child: ExpansionTile(
        title: Text(
          faq['question'],
          style: AppTheme.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          faq['category'],
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.primaryColor,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Text(
              faq['answer'],
              style: AppTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTroubleshootingCard(String title, String solution, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
      decoration: AppTheme.cardDecoration(elevated: true),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppTheme.spacingS),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: AppTheme.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          solution,
          style: AppTheme.bodySmall,
        ),
      ),
    );
  }

  void _handleContactMethod(Map<String, dynamic> method) {
    final action = method['action'];
    final title = method['title'];
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening $title: $action'),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Text('Choose your preferred contact method:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleContactMethod(_contactMethods[0]); // Email
            },
            style: AppTheme.primaryButtonStyle,
            child: const Text('Contact'),
          ),
        ],
      ),
    );
  }

  void _submitFeedback(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit Feedback'),
        content: const TextField(
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Tell us about your experience...',
            border: OutlineInputBorder(),
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
                  content: const Text('Thank you for your feedback!'),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            style: AppTheme.primaryButtonStyle,
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
} 