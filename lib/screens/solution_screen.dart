import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ai/puzzle_solver.dart';
import '../providers/game_provider.dart';

class SolutionScreen extends ConsumerWidget {
  final SolverResult result;
  const SolutionScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solution Details'),
        leading: BackButton(onPressed: () {
          ref.read(gameProvider.notifier).markSolvedByAi();
          context.go('/home');
        }),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Algorithm: ${result.algorithmName}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            Text('Steps: ${result.steps}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            Text('Nodes Explored: ${result.nodesExplored}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            Text('Time: ${result.executionTime.inMilliseconds} ms', style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
