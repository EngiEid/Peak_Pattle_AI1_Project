import 'package:flutter/material.dart';
import 'Problem_formulation.dart';

class HillClimbingAgent {
  final AIProblem problem;
  Offset currentState;

  HillClimbingAgent(this.problem, this.currentState);

  /// دالة اختيار الخطوة الأفضل (الأعلى ارتفاعاً)
  Offset getNextMove() {
    // 1. الحصول على كل الحركات الممكنة
    List<Offset> actions = problem.getActions();
    
    Offset bestAction = Offset.zero;
    double maxElevation = -1.0; // نبدأ بأقل ارتفاع ممكن

    // 2. تقييم كل حركة واختيار التي تؤدي لأعلى نقطة
    for (var action in actions) {
      Offset nextState = problem.getResult(currentState, action);
      double elevation = problem.getElevation(nextState);
      
      if (elevation > maxElevation) {
        maxElevation = elevation;
        bestAction = action;
      }
    }

    // 3. تحديث الحالة والتحرك نحو القمة
    currentState = problem.getResult(currentState, bestAction);
    return currentState;
  }
}