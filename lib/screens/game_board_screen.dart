import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/game_provider.dart';

class GameBoardScreen extends ConsumerWidget {
  const GameBoardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final theme = Theme.of(context);

    // Helper formatting for time
    String formatTime(int seconds) {
      return '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Board'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: () => ref.read(gameProvider.notifier).shuffle(),
            tooltip: 'Shuffle',
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatBadge(label: 'Moves', value: gameState.moves.toString()),
                _StatBadge(label: 'Time', value: formatTime(gameState.elapsedSeconds)),
              ],
            ),
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
                ],
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, index) {
                    final value = gameState.board[index];
                    return value == 0
                        ? const SizedBox.shrink()
                        : GestureDetector(
                            onTap: () => ref.read(gameProvider.notifier).moveTile(index),
                            child: Container(
                              decoration: BoxDecoration(
                                color: theme.primaryColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: Text(
                                  value.toString(),
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                  },
                ),
              ),
            ),
            if (gameState.isSolved)
              Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: Text('🎉 Puzzle Solved! 🎉', style: theme.textTheme.headlineSmall?.copyWith(color: Colors.green, fontWeight: FontWeight.bold)),
              ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton.icon(
                onPressed: () => context.push('/ai_solve'),
                icon: const Icon(Icons.psychology),
                label: const Text('Solve with AI', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  backgroundColor: theme.colorScheme.secondary,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  const _StatBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
