import 'dart:math';
import 'package:flutter/material.dart';
import '../Problem_formulation.dart';

class NaiveAgent {
  final AIProblem problem;
  Offset currentState;
  final Random _random = Random();

  NaiveAgent(this.problem, this.currentState);

  Offset getNextMove() {
    List<Offset> actions = problem.getActions();
    Offset randomAction = actions[_random.nextInt(actions.length)];
    currentState = problem.getResult(currentState, randomAction);
    
    return currentState;
  }
}