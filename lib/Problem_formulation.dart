import 'package:flutter/material.dart';
import 'map_logic.dart';

/// كلاس يمثل صياغة المشكلة للـ AI Agent
/// يتبع نمط الـ State Space Search
class AIProblem {
  final MapData mapData;
  final double stepSize;

  AIProblem(this.mapData, this.stepSize);

  /// الحالة الابتدائية (Initial State)
  /// يمكننا جعل الـ AI يبدأ من زاوية بعيدة عن اللاعب
  Offset get initialState => const Offset(0, 0);

  /// اختبار الهدف (Goal Test)
  /// هل الإحداثيات الحالية هي نفسها إحداثيات القمة؟
  bool isGoal(Offset state) {
    return state == mapData.globalPeakPos;
  }

  /// الحركات المتاحة (Actions)
  /// تعيد قائمة بالإزاحات الممكنة (أعلى، أسفل، يمين، يسار)
  List<Offset> getActions() {
    return [
      Offset(0, stepSize),  // Up
      Offset(0, -stepSize), // Down
      Offset(stepSize, 0),  // Right
      Offset(-stepSize, 0), // Left
    ];
  }

  /// دالة الانتقال (Result/Transition Model)
  /// تعطينا الموقع الجديد بعد الحركة مع ضمان البقاء داخل حدود الخريطة
  Offset getResult(Offset currentState, Offset action) {
    double nextX = (currentState.dx + action.dx).clamp(0.0, 199.0);
    double nextY = (currentState.dy + action.dy).clamp(0.0, 199.0);
    return Offset(nextX, nextY);
  }

  /// دالة التكلفة أو التقييم (Heuristic / Value)
  /// في الـ Hill Climbing نحتاج لمعرفة "الارتفاع" عند نقطة معينة
  double getElevation(Offset state) {
    int x = state.dx.toInt();
    int y = state.dy.toInt();
    // نضمن عدم الخروج عن حدود المصفوفة أثناء القراءة
    x = x.clamp(0, mapData.gridSize - 1);
    y = y.clamp(0, mapData.gridSize - 1);
    return mapData.grid[y][x];
  }

  /// دالة حساب المسافة المباشرة للهدف (Manhattan Distance)
  /// مفيدة جداً لخوارزميات مثل A* لاحقاً
  double getDistanceToGoal(Offset state) {
    return (state.dx - mapData.globalPeakPos.dx).abs() + 
           (state.dy - mapData.globalPeakPos.dy).abs();
  }
}