import 'package:flutter/material.dart';
import 'Gui/map_logic.dart';

class AIProblem {
  final MapData mapData;
  final double stepSize;

  AIProblem(this.mapData, this.stepSize);

  Offset get initialState => const Offset(0, 0);
  bool isGoal(Offset state) {
    return state == mapData.globalPeakPos;
  }

  List<Offset> getActions() {
    return [
      Offset(0, stepSize),  
      Offset(0, -stepSize), 
      Offset(stepSize, 0),  
      Offset(-stepSize, 0), 
    ];
  }

  Offset getResult(Offset currentState, Offset action) {
    double nextX = (currentState.dx + action.dx).clamp(0.0, 199.0);
    double nextY = (currentState.dy + action.dy).clamp(0.0, 199.0);
    return Offset(nextX, nextY);
  }

  double getElevation(Offset state) {
    int x = state.dx.toInt();
    int y = state.dy.toInt();
    x = x.clamp(0, mapData.gridSize - 1);
    y = y.clamp(0, mapData.gridSize - 1);
    return mapData.grid[y][x];
  }

  double getDistanceToGoal(Offset state) {
    return (state.dx - mapData.globalPeakPos.dx).abs() + 
           (state.dy - mapData.globalPeakPos.dy).abs();
  }
}