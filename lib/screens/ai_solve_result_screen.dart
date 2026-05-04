import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import '../ai/puzzle_solver.dart';

class AiSolveResultScreen extends ConsumerStatefulWidget {
  const AiSolveResultScreen({Key? key}) : super(key: key);
  @override
  ConsumerState<AiSolveResultScreen> createState() => _AiSolveResultScreenState();
}

class _AiSolveResultScreenState extends ConsumerState<AiSolveResultScreen> {
  bool _isSolving = false;
  SolverResult? _result;
  String _algo = 'BFS';

  void _solve() async {
    setState(() => _isSolving = true);
    final board = ref.read(gameProvider).board;
    await Future.delayed(const Duration(milliseconds: 50));
    final res = await compute(_algo == 'BFS' ? PuzzleSolver.solveBFS : PuzzleSolver.solveAStar, board);
    setState(() {
      _result = res;
      _isSolving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Solver')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButton<String>(
            value: _algo,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: 'BFS', child: Text('Breadth-First Search')),
              DropdownMenuItem(value: 'A*', child: Text('A* Search')),
            ],
            onChanged: (v) => setState(() => _algo = v!),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isSolving ? null : _solve,
            child: Text(_isSolving ? 'Solving...' : 'Solve Now'),
          ),
          if (_result != null) ...[
            const SizedBox(height: 16),
            Text('Algorithm: ${_result!.algorithmName}'),
            Text('Steps: ${_result!.path.length - 1}'),
            Text('Nodes Explored: ${_result!.nodesExplored}'),
            Text('Time: ${_result!.executionTime.inMilliseconds} ms'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.push('/solution', extra: _result),
              child: const Text('View Solution'),
            ),
          ]
        ],
      ),
    );
  }
}
