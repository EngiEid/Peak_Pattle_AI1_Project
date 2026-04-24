import 'dart:collection';
import 'package:flutter/material.dart';
import 'Problem_formulation.dart';
import 'graph_factory.dart'; 

class BFSAgent {
  final AIProblem problem;
  final Map<Offset, List<Offset>> graph;
  List<Offset> nodePath = [];
  int nextNodeIndex = 0;
  Offset currentState;

  BFSAgent(this.problem, List<Offset> allPeaks, this.currentState)
      : graph = GraphFactory.buildConnectedGraph(
          startPos: currentState,
          peaks: allPeaks,
          k: 5, 
        ) {
    _solveTrueBFS(currentState);
  }

  void _solveTrueBFS(Offset start) {
    Queue<Offset> queue = Queue();
    Set<Offset> visited = {start};
    queue.add(start);

    while (queue.isNotEmpty) {
      Offset currentNode = queue.removeFirst();
      nodePath.add(currentNode);

      if ((currentNode - problem.mapData.globalPeakPos).distance < 1.0) return;

      for (Offset neighbor in graph[currentNode] ?? []) {
        if (!visited.contains(neighbor)) {
          visited.add(neighbor);
          queue.add(neighbor);
        }
      }
    }
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