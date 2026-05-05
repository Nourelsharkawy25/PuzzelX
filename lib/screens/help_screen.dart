import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Help & About')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionTitle('How to Play'),
            const Text(
              'The 8-puzzle is a sliding puzzle that consists of a frame of numbered square tiles in random order with one tile missing. \n\n'
              'Tap a tile adjacent to the empty space to slide it into the empty space. '
              'The goal is to arrange the tiles in numerical order securely from 1 to 8 with the blank space at the bottom right.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 32),
            _SectionTitle('AI Solvers'),
            const Text(
              '• Breadth-First Search (BFS): Explores all possible moves level by level. It guarantees the shortest path but is very memory intensive.\n\n'
              '• A* Search: Uses the Manhattan distance heuristic to intelligently estimate the distance to the goal. It finds the shortest path much faster than BFS in most cases.',
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 32),
            _SectionTitle('About'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('Puzzel X Puzzel', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor)),
                    const SizedBox(height: 8),
                    const Text('Version 1.0.0'),
                    const Divider(height: 32),
                    const Text('Developed by team', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),
                    const Text('Puzzel X Puzzel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
