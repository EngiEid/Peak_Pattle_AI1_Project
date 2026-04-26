import 'package:flutter/material.dart';
import '../Problem_formulation.dart';
import '../graph_factory.dart';

class AStarAgent {
  final AIProblem problem;
  final Map<Offset, List<Offset>> graph;
  List<Offset> nodePath = [];
  int nextNodeIndex = 0;
  Offset currentState;

  AStarAgent(this.problem, List<Offset> allPeaks, this.currentState)
      : graph = GraphFactory.buildConnectedGraph(
          startPos: currentState,
          peaks: allPeaks,
          k: 5,
        ) {
    _solveAStar(currentState);
  }

  double _heuristic(Offset node) {
    return problem.getDistanceToGoal(node);
  }

  void _solveAStar(Offset start) {
    List<Offset> openSet = [start];
    
    Map<Offset, Offset?> parent = {start: null};

    Map<Offset, double> gScore = {start: 0.0};

    Map<Offset, double> fScore = {start: _heuristic(start)};

    while (openSet.isNotEmpty) {
      openSet.sort((a, b) => fScore[a]!.compareTo(fScore[b]!));
      Offset current = openSet.removeAt(0);

      if ((current - problem.mapData.globalPeakPos).distance < 1.0) {
        _reconstructPath(parent, current);
        return;
      }

      for (Offset neighbor in graph[current] ?? []) {
        double tentativeGScore = gScore[current]! + (current - neighbor).distance;

        if (!gScore.containsKey(neighbor) || tentativeGScore < gScore[neighbor]!) {
          parent[neighbor] = current;
          gScore[neighbor] = tentativeGScore;
          fScore[neighbor] = gScore[neighbor]! + _heuristic(neighbor);

          if (!openSet.contains(neighbor)) {
            openSet.add(neighbor);
          }
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
    double step = 3.8;
    currentState += Offset((dx / distance) * step, (dy / distance) * step);
    return currentState;
  }
}