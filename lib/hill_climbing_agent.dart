import 'dart:math';
import 'package:flutter/material.dart';
import 'Problem_formulation.dart';

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

    // 1. البحث عن أفضل حركة في الاتجاهات الأربعة (Steepest Ascent)
    for (var action in actions) {
      Offset nextState = problem.getResult(currentState, action);
      double elevation = problem.getElevation(nextState);
      
      if (elevation > maxElevation) {
        maxElevation = elevation;
        bestAction = action;
        foundBetter = true;
      }
    }

    // 2. إذا لم نجد حركة للأعلى، فهذا يعني أننا في Local Peak
    if (!foundBetter) {
      // نتحقق: هل وصلنا للـ Global Peak فعلاً؟
      if (problem.isGoal(currentState)) {
        return currentState; // مبروك وصلنا للهدف النهائي
      } else {
        // الـ Random Restart: القفز لمكان عشوائي تماماً في الخريطة
        double randomX = _random.nextDouble() * 199.0;
        double randomY = _random.nextDouble() * 199.0;
        currentState = Offset(randomX, randomY);
        return currentState; 
      }
    }

    // 3. التحرك للخطوة الأفضل
    currentState = problem.getResult(currentState, bestAction);
    return currentState;
  }
}