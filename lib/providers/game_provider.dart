import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import '../ai/puzzle_solver.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';
import '../models/game_model.dart';

class GameState {
  final List<int> board;
  final int moves;
  final int elapsedSeconds;
  final bool isSolved;
  final bool isSolvable;

  GameState({
    required this.board,
    this.moves = 0,
    this.elapsedSeconds = 0,
    this.isSolved = false,
    this.isSolvable = true,
  });

  GameState copyWith({
    List<int>? board,
    int? moves,
    int? elapsedSeconds,
    bool? isSolved,
    bool? isSolvable,
  }) {
    return GameState(
      board: board ?? this.board,
      moves: moves ?? this.moves,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isSolved: isSolved ?? this.isSolved,
      isSolvable: isSolvable ?? this.isSolvable,
    );
  }
}

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  ref.watch(authStateProvider); // Recreate the game state whenever auth state changes
  return GameNotifier(ref);
});

class GameNotifier extends StateNotifier<GameState> {
  final Ref ref;
  Timer? _timer;

  GameNotifier(this.ref) : super(GameState(board: _generateSolvedBoard())) {
    _initNewGame();
  }

  static List<int> _generateSolvedBoard() => [1, 2, 3, 4, 5, 6, 7, 8, 0];

  void _initNewGame() {
    _timer?.cancel();
    List<int> newBoard;
    do {
      newBoard = List<int>.from(_generateSolvedBoard());
      newBoard.shuffle();
    } while (PuzzleSolver.solveAStar(newBoard) == null || const ListEquality().equals(newBoard, _generateSolvedBoard()));

    state = GameState(
      board: newBoard,
      moves: 0,
      elapsedSeconds: 0,
      isSolved: false,
      isSolvable: true,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!state.isSolved) {
        state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
      } else {
        timer.cancel();
      }
    });
  }

  void shuffle() {
    _initNewGame();
  }

  void moveTile(int index) {
    if (state.isSolved) return;

    int blankIndex = state.board.indexOf(0);
    int blankRow = blankIndex ~/ 3;
    int blankCol = blankIndex % 3;
    int tileRow = index ~/ 3;
    int tileCol = index % 3;

    if ((blankRow - tileRow).abs() + (blankCol - tileCol).abs() == 1) {
      List<int> newBoard = List.from(state.board);
      newBoard[blankIndex] = newBoard[index];
      newBoard[index] = 0;

      bool solved = const ListEquality().equals(newBoard, _generateSolvedBoard());

      state = state.copyWith(
        board: newBoard,
        moves: state.moves + 1,
        isSolved: solved,
      );

      if (solved) {
        _timer?.cancel();
        _saveGame(usedAi: false);
      }
    }
  }

  Future<void> _saveGame({required bool usedAi}) async {
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      final model = GameModel(
        id: '',
        uid: user.uid,
        playerName: user.name,
        puzzleState: state.board,
        moves: state.moves,
        timeSeconds: state.elapsedSeconds,
        solved: true,
        algorithmUsed: usedAi ? 'AI' : 'None',
      );
      await FirestoreService.instance.saveGame(model);
      await FirestoreService.instance.incrementUserStats(
        user.uid,
        usedAi: usedAi,
        moves: state.moves,
      );
    }
  }

  // To be called when AI finishes solving it via the step-by-step viewer 
  void markSolvedByAi() {
      state = state.copyWith(isSolved: true, board: _generateSolvedBoard());
      _timer?.cancel();
      _saveGame(usedAi: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
