import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ai/puzzle_solver.dart';
import '../providers/game_provider.dart';

class SolutionPathScreen extends ConsumerStatefulWidget {
  final SolverResult result;
  const SolutionPathScreen({Key? key, required this.result}) : super(key: key);

  @override
  ConsumerState<SolutionPathScreen> createState() => _SolutionPathScreenState();
}

class _SolutionPathScreenState extends ConsumerState<SolutionPathScreen> {
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    final board = widget.result.path[_step];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solution Viewer'),
        leading: BackButton(onPressed: () {
          ref.read(gameProvider.notifier).markSolvedByAi();
          context.go('/home');
        }),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Step $_step / ${widget.result.path.length - 1}', style: const TextStyle(fontSize: 24)),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(32),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: 9,
              itemBuilder: (context, i) => Container(
                color: board[i] == 0 ? Colors.transparent : Colors.blue,
                alignment: Alignment.center,
                child: Text(
                  board[i] == 0 ? '' : '${board[i]}',
                  style: const TextStyle(fontSize: 32, color: Colors.white),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _step > 0 ? () => setState(() => _step--) : null,
                child: const Text('Prev'),
              ),
              ElevatedButton(
                onPressed: _step < widget.result.path.length - 1 ? () => setState(() => _step++) : null,
                child: const Text('Next'),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
