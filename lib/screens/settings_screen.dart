import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Text('Preferences', style: theme.textTheme.titleMedium?.copyWith(color: theme.primaryColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          SwitchListTile(
            title: const Text('Dark Mode'),
            value: settings.isDarkMode,
            onChanged: settingsNotifier.toggleDarkMode,
            activeColor: theme.primaryColor,
          ),
          const Divider(height: 48),
          Text('Game & AI', style: theme.textTheme.titleMedium?.copyWith(color: theme.primaryColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Default AI Algorithm'),
            trailing: DropdownButton<String>(
              value: settings.defaultAlgorithm,
              items: const [
                DropdownMenuItem(value: 'BFS', child: Text('BFS')),
                DropdownMenuItem(value: 'A*', child: Text('A* Search')),
              ],
              onChanged: (val) {
                if (val != null) settingsNotifier.setDefaultAlgorithm(val);
              },
            ),
          ),
        ],
      ),
    );
  }
}
