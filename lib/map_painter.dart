import 'package:flutter/material.dart';
import 'map_logic.dart';

class MapPainter extends CustomPainter {
  final MapData mapData;
  final Offset playerPos;
  final Offset aiPos;
  final bool showGraph;
  final Map<Offset, List<Offset>>? aiGraph;
  final List<Offset>? aiNodePath; // <--- التعديل الجديد لاستقبال المسار

  MapPainter(this.mapData, this.playerPos, {
    required this.aiPos,
    required this.showGraph, 
    this.aiGraph,
    this.aiNodePath, // <--- تمرير المسار هنا
  });

  Offset _mapToCanvas(Offset pos, Size size) {
    double cellW = size.width / mapData.gridSize;
    double cellH = size.height / mapData.gridSize;
    
    return Offset(
      pos.dx * cellW,
      (mapData.gridSize - pos.dy) * cellH,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 1. رسم الخلفية
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), 
        Paint()..color = const Color(0xFFE2D1B3));

    // 2. رسم الخطوط الكونتورية (الجبال)
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

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

    // 3. رسم الجراف والمسار المختار
    if (showGraph && aiGraph != null) {
      // أ- رسم الجراف بالكامل بلون شفاف وباهت (Background Graph)
      final graphPaint = Paint()
        ..color = Colors.cyanAccent.withOpacity(0.15) 
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      aiGraph!.forEach((startNode, neighbors) {
        for (var endNode in neighbors) {
          canvas.drawLine(
            _mapToCanvas(startNode, size), 
            _mapToCanvas(endNode, size), 
            graphPaint
          );
        }
      });

      // ب- رسم المسار المختار بلون ساطع (The Solution Path)
      if (aiNodePath != null && aiNodePath!.isNotEmpty) {
        final pathPaint = Paint()
          ..color = Colors.yellowAccent // لون المسار المختار (ذهبي/أصفر ساطع)
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

        // رسم "وهج" خلف المسار لتمييزه
        final glowPaint = Paint()
          ..color = Colors.yellowAccent.withOpacity(0.3)
          ..strokeWidth = 6.0
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

        for (int i = 0; i < aiNodePath!.length - 1; i++) {
          Offset p1 = _mapToCanvas(aiNodePath![i], size);
          Offset p2 = _mapToCanvas(aiNodePath![i + 1], size);
          canvas.drawLine(p1, p2, glowPaint); // رسم الوهج
          canvas.drawLine(p1, p2, pathPaint);   // رسم الخط الأساسي
        }

        // رسم العقد الموجودة على المسار فقط بلون ساطع
        final pathNodePaint = Paint()..color = Colors.yellowAccent;
        for (var node in aiNodePath!) {
          canvas.drawCircle(_mapToCanvas(node, size), 3.5, pathNodePaint);
        }
      } else {
        // لو مفيش مسار، ارسم العقد العادية بلون باهت
        final nodePaint = Paint()..color = Colors.cyanAccent;
        aiGraph!.keys.forEach((node) {
          canvas.drawCircle(_mapToCanvas(node, size), 2.0, nodePaint);
        });
      }
    }

    // 4. رسم اللاعب (Human)
    Offset pCanvas = _mapToCanvas(playerPos, size);
    canvas.drawCircle(pCanvas, 10.5, Paint()..color = Colors.black);
    canvas.drawCircle(pCanvas, 8.5, Paint()..color = const Color(0xFFFFD700));

    // 5. رسم الـ AI
    Offset aCanvas = _mapToCanvas(aiPos, size);
    canvas.drawCircle(aCanvas, 9.5, Paint()..color = Colors.black);
    canvas.drawCircle(aCanvas, 7.5, Paint()..color = Colors.redAccent);
  }

  @override
  bool shouldRepaint(MapPainter oldDelegate) => true;
}