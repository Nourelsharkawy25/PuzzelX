import 'dart:collection';
import 'package:collection/collection.dart';

class SolverResult {
  final List<List<int>> path;
  final int nodesExplored;
  final Duration executionTime;
  final String algorithmName;

  SolverResult({
    required this.path,
    required this.nodesExplored,
    required this.executionTime,
    required this.algorithmName,
  });
}

const List<int> GOAL = [1, 2, 3, 4, 5, 6, 7, 8, 0];
const dx4 = [0, 1, 0, -1];
const dy4 = [1, 0, -1, 0];

bool valid(int x, int y, int n, int m) {
  return x >= 0 && x < n && y >= 0 && y < m;
}

List<List<int>> get_childs(List<int> u) {
  List<List<int>> res = [];
  int x = 0, y = 0;

  for (int i = 0; i < 3; ++i) {
    for (int j = 0; j < 3; ++j) {
      if (u[i * 3 + j] == 0) {
        x = i;
        y = j;
        break;
      }
    }
  }

  for (int i = 0; i < 4; ++i) {
    int nx = x + dx4[i];
    int ny = y + dy4[i];

    if (valid(nx, ny, 3, 3)) {
      List<int> temp = List.from(u);
      int tempVal = temp[x * 3 + y];
      temp[x * 3 + y] = temp[nx * 3 + ny];
      temp[nx * 3 + ny] = tempVal;
      res.add(temp);
    }
  }

  return res;
}

int hx(List<int> puzzle) {
  int cnt = 0, pos = 1;
  for (int i = 0; i < 3; ++i) {
    for (int j = 0; j < 3; ++j) {
      int val = puzzle[i * 3 + j];
      if (val == 0) continue;
      if (val != pos) cnt++;
      pos++;
    }
  }
  return cnt;
}

List<MapEntry<List<int>, int>> get_childs_astar(List<int> u, int g) {
  List<MapEntry<List<int>, int>> res = [];
  int x = 0, y = 0;

  for (int i = 0; i < 3; ++i) {
    for (int j = 0; j < 3; ++j) {
      if (u[i * 3 + j] == 0) {
        x = i;
        y = j;
        break;
      }
    }
  }

  for (int i = 0; i < 4; ++i) {
    int nx = x + dx4[i];
    int ny = y + dy4[i];

    if (valid(nx, ny, 3, 3)) {
      List<int> temp = List.from(u);
      int tempVal = temp[x * 3 + y];
      temp[x * 3 + y] = temp[nx * 3 + ny];
      temp[nx * 3 + ny] = tempVal;

      int fx = hx(temp) + (g + 1);
      res.add(MapEntry(temp, fx));
    }
  }

  return res;
}

class Node {
  final List<int> board;
  final Node? parent;
  Node(this.board, this.parent);
}

class AStarNode {
  final List<int> board;
  final int f;
  final int g;
  final AStarNode? parent;
  AStarNode(this.board, this.f, this.g, this.parent);
}

SolverResult _buildResult(dynamic endNode, int explored, DateTime start, String algo) {
  List<List<int>> path = [];
  dynamic current = endNode;
  while (current != null) {
    path.add(current.board);
    current = current.parent;
  }
  return SolverResult(
    path: path.reversed.toList(),
    nodesExplored: explored,
    executionTime: DateTime.now().difference(start),
    algorithmName: algo,
  );
}

class PuzzleSolver {
  static SolverResult? solveBFS(List<int> puzzle) {
    final startTime = DateTime.now();

    Queue<Node> q = Queue();
    Set<String> vis = {};

    q.add(Node(puzzle, null));
    vis.add(puzzle.join(','));

    int nodesExplored = 0;

    while (q.isNotEmpty) {
      int sz = q.length;
      while (sz-- > 0) {
        Node uNode = q.removeFirst();
        List<int> u = uNode.board;
        nodesExplored++;

        if (const ListEquality().equals(u, GOAL)) {
          return _buildResult(uNode, nodesExplored, startTime, 'BFS');
        }

        List<List<int>> neighbors = get_childs(u);
        for (List<int> v in neighbors) {
          String vStr = v.join(',');
          if (!vis.contains(vStr)) {
            q.add(Node(v, uNode));
            vis.add(vStr);
          }
        }
      }
    }

    return null;
  }

  static SolverResult? solveAStar(List<int> puzzle) {
    final startTime = DateTime.now();

    PriorityQueue<AStarNode> pq = PriorityQueue((a, b) => a.f.compareTo(b.f));
    Map<String, int> gMap = {};

    String startHash = puzzle.join(',');
    gMap[startHash] = 0;

    pq.add(AStarNode(puzzle, hx(puzzle), 0, null));
    int nodesExplored = 0;

    while (pq.isNotEmpty) {
      AStarNode top = pq.removeFirst();
      List<int> u = top.board;
      String uHash = u.join(',');
      nodesExplored++;

      if (const ListEquality().equals(u, GOAL)) {
        return _buildResult(top, nodesExplored, startTime, 'A*');
      }

      int currentG = gMap[uHash] ?? top.g;
      
      List<MapEntry<List<int>, int>> neighbors = get_childs_astar(u, currentG);
      for (var neighbor in neighbors) {
        List<int> v = neighbor.key;
        int f_val = neighbor.value;
        String vHash = v.join(',');

        int new_cost = currentG + 1;

        if (!gMap.containsKey(vHash) || new_cost < gMap[vHash]!) {
          gMap[vHash] = new_cost;
          pq.add(AStarNode(v, f_val, new_cost, top));
        }
      }
    }

    return null;
  }

  static bool isSolvable(List<int> puzzle) {
    int inversions = 0;
    List<int> list = puzzle.where((e) => e != 0).toList();
    for (int i = 0; i < list.length - 1; i++) {
        for (int j = i + 1; j < list.length; j++) {
            if (list[i] > list[j]) inversions++;
        }
    }
    return inversions % 2 == 0;
  }
}
