import 'package:flutter/material.dart';

class GraphFactory {
  /// بناء Graph متصل تماماً بحيث كل عقدة مرتبطة بأقرب [k] جيران
  static Map<Offset, List<Offset>> buildConnectedGraph({
    required Offset startPos,
    required List<Offset> peaks,
    int k = 5,
  }) {
    Map<Offset, List<Offset>> graph = {};
    List<Offset> nodes = {startPos, ...peaks}.toList();

    // 1. الربط الأولي (K-Nearest Neighbors)
    for (var node in nodes) {
      List<Offset> others = List.from(nodes)..remove(node);
      others.sort((a, b) => (node - a).distanceSquared.compareTo((node - b).distanceSquared));
      graph[node] = others.take(k).toList();
    }

    // 2. ضمان الاتصال الشامل (Global Connectivity)
    _ensureConnectivity(nodes, startPos, graph);

    return graph;
  }

  static void _ensureConnectivity(List<Offset> nodes, Offset startNode, Map<Offset, List<Offset>> graph) {
    Set<Offset> reachable = _getReachableNodes(startNode, graph);

    while (reachable.length < nodes.length) {
      Offset? bestUnreachable;
      Offset? bestReachable;
      double minDistance = double.infinity;

      for (var un in nodes) {
        if (!reachable.contains(un)) {
          for (var re in reachable) {
            double dist = (un - re).distanceSquared;
            if (dist < minDistance) {
              minDistance = dist;
              bestUnreachable = un;
              bestReachable = re;
            }
          }
        }
      }

      if (bestUnreachable != null && bestReachable != null) {
        graph[bestReachable]!.add(bestUnreachable);
        graph[bestUnreachable]!.add(bestReachable);
        reachable = _getReachableNodes(startNode, graph);
      }
    }
  }

  static Set<Offset> _getReachableNodes(Offset start, Map<Offset, List<Offset>> graph) {
    Set<Offset> visited = {start};
    List<Offset> stack = [start];
    while (stack.isNotEmpty) {
      Offset node = stack.removeLast();
      for (var neighbor in graph[node] ?? []) {
        if (!visited.contains(neighbor)) {
          visited.add(neighbor);
          stack.add(neighbor);
        }
      }
    }
    return visited;
  }
}