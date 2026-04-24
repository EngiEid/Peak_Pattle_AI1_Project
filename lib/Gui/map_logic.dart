import 'dart:math';
import 'package:flutter/material.dart';

class MapData {
  final int gridSize = 200;
  late List<List<double>> grid;
  final int seed;
  late Offset globalPeakPos;

  List<Offset> realPeaksCenters = [];

  MapData(this.seed, {double step = 5.0}) {
    generateNewMap(step);
  }

  void generateNewMap(double step) {
    Random random = Random(seed);
    
    grid = List.generate(gridSize, (y) => List.generate(gridSize, (x) => 0.0));
    realPeaksCenters.clear();

    int numPeaks = 40;
    List<Map<String, dynamic>> peaksMetadata = [];

    for (int i = 0; i < numPeaks; i++) {
      double px = random.nextDouble() * (gridSize - 1);
      double py = random.nextDouble() * (gridSize - 1);

      // Special handling for the Global Peak (First peak)
      if (i == 0) {
        px = 100 + ((px - 100) / step).round() * step;
        py = 100 + ((py - 100) / step).round() * step;
        px = px.clamp(0.0, 199.0);
        py = py.clamp(0.0, 199.0);
        globalPeakPos = Offset(px, py);
      }

      realPeaksCenters.add(Offset(px, py));

      // Higher zValue for the global peak to ensure it's the highest
      double zValue = (i == 0) ? 1.0 : (0.3 + random.nextDouble() * 0.65);
      
      peaksMetadata.add({
        'x': px,
        'y': py,
        'z': zValue,
        'radius': 1800.0 + random.nextDouble() * 2500.0,
      });
    }

    for (var peak in peaksMetadata) {
      double px = peak['x'];
      double py = peak['y'];
      double z = peak['z'];
      double radius = peak['radius'];

      int range = (sqrt(radius) * 2.5).toInt();

      int startX = (px - range).toInt().clamp(0, gridSize - 1);
      int endX = (px + range).toInt().clamp(0, gridSize - 1);
      int startY = (py - range).toInt().clamp(0, gridSize - 1);
      int endY = (py + range).toInt().clamp(0, gridSize - 1);

      for (int y = startY; y <= endY; y++) {
        for (int x = startX; x <= endX; x++) {
          double distSq = (pow((x - px), 2) + pow((y - py), 2)).toDouble();
          
          double val = z * exp(-distSq / radius);
          
          if (val > grid[y][x]) {
            grid[y][x] = val.clamp(0.0, 1.0);
          }
        }
      }
    }
  }

  List<Offset> findAllLocalPeaks() {
    return List.from(realPeaksCenters);
  }
}