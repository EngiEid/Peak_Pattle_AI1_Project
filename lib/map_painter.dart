import 'package:flutter/material.dart';
import 'map_logic.dart';

class MapPainter extends CustomPainter {
  final MapData mapData;
  final Offset playerPos;
  final Offset aiPos;
  final bool showGraph;
  final Map<Offset, List<Offset>>? aiGraph;

  MapPainter(this.mapData, this.playerPos, {
    required this.aiPos,
    required this.showGraph, 
    this.aiGraph
  });

  // --- الدالة المفقودة التي سببت الخطأ ---
  Offset _mapToCanvas(Offset pos, Size size) {
    double cellW = size.width / mapData.gridSize;
    double cellH = size.height / mapData.gridSize;
    
    // تحويل الإحداثيات مع مراعاة أن Y يبدأ من الأسفل في نظام رسم الخريطة لديكِ
    return Offset(
      pos.dx * cellW,
      (mapData.gridSize - pos.dy) * cellH,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    double cellW = size.width / mapData.gridSize;
    double cellH = size.height / mapData.gridSize;

    // رسم الخلفية
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), 
        Paint()..color = const Color(0xFFE2D1B3));

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // رسم خطوط الكنتور
    const int levels = 25; 
    for (int l = 1; l <= levels; l++) {
      double threshold = l / (levels + 1);
      linePaint.color = Color.lerp(
        const Color(0xFF968266).withOpacity(0.5),
        const Color(0xFF423425).withOpacity(0.9),
        threshold
      )!;
      
      linePaint.strokeWidth = 0.9 + (threshold * 0.8);
      Path contourPath = Path();
      for (int i = 0; i < mapData.gridSize - 1; i += 2) {
        for (int j = 0; j < mapData.gridSize - 1; j += 2) {
          if ((mapData.grid[i][j] - threshold).abs() < 0.013) {
            Offset canvasPos = _mapToCanvas(Offset(j.toDouble(), i.toDouble()), size);
            contourPath.addRect(Rect.fromLTWH(canvasPos.dx, canvasPos.dy, 1.2, 1.2));
          }
        }
      }
      canvas.drawPath(contourPath, linePaint);
    }

    // --- رسم الـ Graph (الروابط بين القمم) ---
    if (showGraph && aiGraph != null) {
      final paint = Paint()
        ..color = Colors.cyanAccent.withOpacity(0.4)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;

      aiGraph!.forEach((startNode, neighbors) {
        for (var endNode in neighbors) {
          canvas.drawLine(
            _mapToCanvas(startNode, size), 
            _mapToCanvas(endNode, size), 
            paint
          );
        }
      });

      final nodePaint = Paint()..color = Colors.cyanAccent.withOpacity(0.7);
      aiGraph!.keys.forEach((node) {
        canvas.drawCircle(_mapToCanvas(node, size), 2.5, nodePaint);
      });
    }

    // --- رسم اللاعب ---
    Offset pCanvas = _mapToCanvas(playerPos, size);
    canvas.drawCircle(pCanvas, 10.5, Paint()..color = Colors.black);
    canvas.drawCircle(pCanvas, 8.5, Paint()..color = const Color(0xFFFFD700));

    // --- رسم الـ AI Agent ---
    Offset aCanvas = _mapToCanvas(aiPos, size);
    canvas.drawCircle(aCanvas, 9.5, Paint()..color = Colors.black);
    canvas.drawCircle(aCanvas, 7.5, Paint()..color = Colors.redAccent);
  }

  @override
  bool shouldRepaint(MapPainter oldDelegate) => true;
}