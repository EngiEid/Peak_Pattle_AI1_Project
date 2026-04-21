import 'dart:math';
import 'package:flutter/material.dart';

class MapData {
  final int gridSize = 200;
  late List<List<double>> grid;
  final int seed;
  late Offset globalPeakPos;
  
  // --- التعديل السحري هنا: قائمة لتخزين مراكز القمم الحقيقية ---
  List<Offset> realPeaksCenters = [];

  MapData(this.seed, {double step = 5.0}) {
    generateNewMap(step);
  }

  void generateNewMap(double step) {
    Random random = Random(seed);
    grid = List.generate(gridSize, (y) => List.generate(gridSize, (x) => 0.0));
    realPeaksCenters.clear(); // مسح القائمة القديمة

    int numPeaks = 40;
    List<Map<String, dynamic>> peaksMetadata = [];

    for (int i = 0; i < numPeaks; i++) {
      double px = random.nextDouble() * (gridSize - 1);
      double py = random.nextDouble() * (gridSize - 1);
      
      if (i == 0) {
        px = 100 + ((px - 100) / step).round() * step;
        py = 100 + ((py - 100) / step).round() * step;
        px = px.clamp(0.0, 199.0);
        py = py.clamp(0.0, 199.0);
        globalPeakPos = Offset(px, py);
      }

      // تخزين المركز الحقيقي في القائمة لاستخدامه في الـ Graph
      realPeaksCenters.add(Offset(px, py));

      double zValue = (i == 0) ? 1.0 : (0.3 + random.nextDouble() * 0.65);
      peaksMetadata.add({
        'x': px, 'y': py, 'z': zValue,
        'radius': 1800.0 + random.nextDouble() * 2500.0,
      });
    }

    // بناء المصفوفة (الجريد) بناءً على مراكز القمم
    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        double currentMax = 0.0;
        for (var peak in peaksMetadata) {
          double distSq = (pow((x - peak['x']), 2) + pow((y - peak['y']), 2)).toDouble();
          double val = peak['z'] * exp(-distSq / peak['radius']);
          if (val > currentMax) currentMax = val;
        }
        grid[y][x] = currentMax.clamp(0.0, 1.0);
      }
    }
  }

  // الآن هذه الدالة أصبحت بسيطة جداً ومضمونة لأنها ترجع البيانات المخزنة
  List<Offset> findAllLocalPeaks() {
    return List.from(realPeaksCenters);
  }
}