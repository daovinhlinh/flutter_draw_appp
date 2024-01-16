import 'package:flutter/material.dart';
import 'package:flutter_draw_appp/view/models/drawing_mode.dart';

class Sketch {
  final List<Offset> points;
  final Color color;
  final double size;
  final SketchType type;
  final bool filled;
  final int sides;

  Sketch(
      {required this.points,
      required this.color,
      required this.size,
      this.type = SketchType.pencil,
      this.filled = false,
      this.sides = 3});

  factory Sketch.fromDrawingMode(
    Sketch sketch,
    DrawingMode drawingMode,
    bool filled,
  ) {
    return Sketch(
      points: sketch.points,
      color: sketch.color,
      size: sketch.size,
      filled: drawingMode == DrawingMode.line ||
              drawingMode == DrawingMode.pencil ||
              drawingMode == DrawingMode.eraser
          ? false
          : filled,
      sides: sketch.sides,
      type: () {
        switch (drawingMode) {
          case DrawingMode.eraser:
          case DrawingMode.pencil:
            return SketchType.pencil;
          case DrawingMode.line:
            return SketchType.line;
          case DrawingMode.square:
            return SketchType.square;
          case DrawingMode.circle:
            return SketchType.circle;
          case DrawingMode.polygon:
            return SketchType.polygon;
          default:
            return SketchType.pencil;
        }
      }(),
    );
  }
}

enum SketchType { pencil, line, square, circle, polygon }
