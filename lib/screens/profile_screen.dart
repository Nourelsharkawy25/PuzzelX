import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameCtrl = TextEditingController();

  Future<void> _updateName() async {
    final user = ref.read(authStateProvider).value;
    if (user != null && _nameCtrl.text.isNotEmpty) {
      final updatedUser = user.copyWith(name: _nameCtrl.text.trim());
      await FirestoreService.instance.saveUser(updatedUser);
      // Wait for auth stream to reflect or just show success
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name updated successfully')));
    }
  }

  void _signOut() async {
    await ref.read(authControllerProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    final theme = Theme.of(context);

    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    _nameCtrl.text = user.name;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircleAvatar(radius: 50, backgroundColor: theme.primaryColor, child: const Icon(Icons.person, size: 50, color: Colors.white)),
            const SizedBox(height: 24),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Player Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _updateName, child: const Text('Save Changes')),
            const Divider(height: 64),
            Text('Account Statistics', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(title: const Text('Games Played'), trailing: Text(user.gamesPlayed.toString())),
                    ListTile(title: const Text('Best Moves'), trailing: Text(user.bestMoves == -1 ? 'None' : user.bestMoves.toString())),
                    ListTile(title: const Text('AI Assists'), trailing: Text(user.aiSolves.toString())),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: _signOut,
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Sign Out'),
            )
          ],
        ),
      ),
    );
  }
}
