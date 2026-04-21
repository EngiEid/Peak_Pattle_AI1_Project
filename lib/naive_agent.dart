import 'dart:math';
import 'package:flutter/material.dart';
import 'Problem_formulation.dart';

class NaiveAgent {
  final AIProblem problem;
  Offset currentState;
  final Random _random = Random();

  NaiveAgent(this.problem, this.currentState);

  /// دالة اختيار الخطوة القادمة (بشكل عشوائي تماماً)
  Offset getNextMove() {
    // 1. الحصول على كل الحركات الممكنة من تعريف المشكلة
    List<Offset> actions = problem.getActions();
    
    // 2. اختيار حركة واحدة عشوائياً
    Offset randomAction = actions[_random.nextInt(actions.length)];
    
    // 3. تحديث الحالة بناءً على الحركة المختارة
    currentState = problem.getResult(currentState, randomAction);
    
    return currentState;
  }
}