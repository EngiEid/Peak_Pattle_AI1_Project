import 'dart:math';
import 'package:flutter/material.dart';
import '../Problem_formulation.dart';

class HillClimbingAgent {
  final AIProblem problem;
  Offset currentState;
  final Random _random = Random();

  HillClimbingAgent(this.problem, this.currentState);

  Offset getNextMove() {
    List<Offset> actions = problem.getActions();
    
    Offset bestAction = Offset.zero;
    double currentElevation = problem.getElevation(currentState);
    double maxElevation = currentElevation;
    bool foundBetter = false;

    for (var action in actions) {
      Offset nextState = problem.getResult(currentState, action);
      double elevation = problem.getElevation(nextState);
      
      if (elevation > maxElevation) {
        maxElevation = elevation;
        bestAction = action;
        foundBetter = true;
      }
    }

    if (!foundBetter) {
      if (problem.isGoal(currentState)) {
        return currentState; 
      } else {
        double randomX = _random.nextDouble() * 199.0;
        double randomY = _random.nextDouble() * 199.0;
        currentState = Offset(randomX, randomY);
        return currentState; 
      }
    }

    currentState = problem.getResult(currentState, bestAction);
    return currentState;
  }
}