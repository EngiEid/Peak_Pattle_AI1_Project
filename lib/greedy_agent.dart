import 'package:flutter/material.dart';
import 'Problem_formulation.dart';
import 'graph_factory.dart';

class GreedyAgent {
  final AIProblem problem;
  final Map<Offset, List<Offset>> graph;
  List<Offset> nodePath = [];
  int nextNodeIndex = 0;
  Offset currentState;

  GreedyAgent(this.problem, List<Offset> allPeaks, this.currentState)
      : graph = GraphFactory.buildConnectedGraph(
          startPos: currentState,
          peaks: allPeaks,
          k: 5,
        ) {
    _solveGreedy(currentState);
  }

  double _heuristic(Offset node) {
    return (node - problem.mapData.globalPeakPos).distance;
  }

  void _solveGreedy(Offset start) {
    List<Offset> openSet = [start];
    Map<Offset, Offset?> parent = {start: null};
    Set<Offset> visited = {start};

    while (openSet.isNotEmpty) {
      // Greedy بيختار النقطة اللي ليها أقل Heuristic فقط
      openSet.sort((a, b) => _heuristic(a).compareTo(_heuristic(b)));
      Offset current = openSet.removeAt(0);

      if ((current - problem.mapData.globalPeakPos).distance < 1.0) {
        _reconstructPath(parent, current);
        return;
      }

      for (Offset neighbor in graph[current] ?? []) {
        if (!visited.contains(neighbor)) {
          visited.add(neighbor);
          parent[neighbor] = current;
          openSet.add(neighbor);
        }
      }
    }
  }

  void _reconstructPath(Map<Offset, Offset?> parent, Offset current) {
    List<Offset> path = [];
    Offset? temp = current;
    while (temp != null) {
      path.add(temp);
      temp = parent[temp];
    }
    nodePath = path.reversed.toList();
  }

  Offset getNextMove() {
    if (nodePath.isEmpty || nextNodeIndex >= nodePath.length) return currentState;
    Offset targetNode = nodePath[nextNodeIndex];
    double dx = targetNode.dx - currentState.dx;
    double dy = targetNode.dy - currentState.dy;
    double distance = Offset(dx, dy).distance;

    if (distance < 2.0) {
      nextNodeIndex++;
      return currentState;
    }
    double step = 4.0; 
    currentState += Offset((dx / distance) * step, (dy / distance) * step);
    return currentState;
  }
}