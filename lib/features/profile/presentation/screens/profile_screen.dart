import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendura/core/theme/app_theme.dart';
import 'package:vendura/core/services/mock_service.dart' show currentUserProvider, MockService;

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    print('[ProfileScreen] build: user = ' + (user?.toString() ?? 'null'));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(user),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.person, size: 40),
                title: Text(user?['displayName'] ?? 'Guest', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(user?['email'] ?? ''),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _signOut,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed, foregroundColor: Colors.white),
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic>? user) {
    print('[ProfileScreen] _showEditDialog called');
    final nameCtrl = TextEditingController(text: user?['displayName'] ?? '');
    final emailCtrl = TextEditingController(text: user?['email'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              print('[ProfileScreen] Save pressed: name=' + nameCtrl.text + ', email=' + emailCtrl.text);
              await MockService.updateCurrentUser(
                displayName: nameCtrl.text.trim(),
                email: emailCtrl.text.trim(),
              );
              // refresh provider
              ref.read(currentUserProvider.notifier).state = MockService.currentUser;
              if (mounted) Navigator.pop(context);
            },
            style: AppTheme.primaryButtonStyle,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _signOut() async {
    print('[ProfileScreen] Sign out pressed');
    await MockService.signOut();
    ref.read(currentUserProvider.notifier).state = null;
    if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
  }
} 