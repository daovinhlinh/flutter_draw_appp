import 'dart:ui';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter_draw_appp/main.dart';
import 'package:flutter_draw_appp/view/models/drawing_mode.dart';
import 'package:flutter_draw_appp/view/models/sketch.dart';
import 'dart:math' show pi, sin, cos;

import 'package:flutter_hooks/flutter_hooks.dart';

class DrawingCanvas extends HookWidget {
  final double width, height;
  final ValueNotifier<double> strokeSize, eraserSize;
  final ValueNotifier<int> polygonSides;
  final ValueNotifier<Image?> backgroundImage;
  final ValueNotifier<bool> filled;
  final ValueNotifier<Color> selectedColor;
  final ValueNotifier<DrawingMode> drawingMode;
  final GlobalKey canvasGlobalKey;
  final ValueNotifier<Sketch?> currentSketch;
  final ValueNotifier<List<Sketch>> allSketches;
  final AnimationController sideBarController;

  const DrawingCanvas(
      {required this.height,
      required this.width,
      required this.drawingMode,
      required this.eraserSize,
      required this.strokeSize,
      required this.polygonSides,
      required this.filled,
      required this.canvasGlobalKey,
      required this.backgroundImage,
      required this.currentSketch,
      required this.allSketches,
      required this.sideBarController,
      required this.selectedColor,
      super.key});

//Animation can cause another widget repaint => RepaintBoundary separating child widget to its own layer

  void onPointerUp(_) {
    // print("pointer")
    // allSketches.value = [
    //   ...allSketches.value,
    //   currentSketch.value!,
    // ];

    final newAllSketches = List<Sketch>.from(allSketches.value)
      ..add(currentSketch.value!);

    allSketches.value = newAllSketches;

    currentSketch.value = Sketch.fromDrawingMode(
      Sketch(
        points: [],
        size: drawingMode.value == DrawingMode.eraser
            ? eraserSize.value
            : strokeSize.value,
        color: drawingMode.value == DrawingMode.eraser
            ? kCanvasColor
            : selectedColor.value,
        sides: polygonSides.value,
      ),
      drawingMode.value,
      filled.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      SizedBox(
        height: height,
        width: width,
        child: ValueListenableBuilder<List<Sketch>>(
          valueListenable: allSketches,
          builder: (context, sketches, _) {
            return RepaintBoundary(
              key: canvasGlobalKey,
              child: SizedBox(
                height: height,
                width: width,
                child: CustomPaint(
                  isComplex: true,
                  willChange: false,
                  foregroundPainter: SketchPainter(sketches: allSketches.value),
                ),
              ),
            );
          },
        ),
      ),
      Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (details) {
          final box = context.findRenderObject() as RenderBox;
          final offset = box.globalToLocal(details.position);
          print("pointer down");
          currentSketch.value = Sketch(
              points: [offset],
              color: drawingMode.value == DrawingMode.eraser
                  ? kCanvasColor
                  : selectedColor.value,
              size: drawingMode.value == DrawingMode.eraser
                  ? eraserSize.value
                  : strokeSize.value,
              type: () {
                switch (drawingMode.value) {
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
              sides: polygonSides.value,
              filled: filled.value &&
                  drawingMode.value != DrawingMode.pencil &&
                  drawingMode.value != DrawingMode.eraser);
        },
        onPointerUp: onPointerUp,
        onPointerMove: (details) {
          final box = context.findRenderObject() as RenderBox;
          final offset = box.globalToLocal(details.position);

          final point = List<Offset>.from(currentSketch.value?.points ?? [])
            ..add(offset);

          currentSketch.value = Sketch(
            points: point,
            color: drawingMode.value == DrawingMode.eraser
                ? kCanvasColor
                : selectedColor.value,
            size: drawingMode.value == DrawingMode.eraser
                ? eraserSize.value
                : strokeSize.value,
            type: () {
              switch (drawingMode.value) {
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
            filled: filled.value &&
                drawingMode.value != DrawingMode.pencil &&
                drawingMode.value != DrawingMode.eraser,
            sides: polygonSides.value,
          ); //TODO: change color and size
        },
        child: ValueListenableBuilder(
          valueListenable: currentSketch,
          builder: (context, sketch, child) {
            return RepaintBoundary(
              child: SizedBox(
                height: height,
                width: width,
                child: CustomPaint(
                  // isComplex: true,
                  // willChange: false,
                  foregroundPainter: SketchPainter(
                      sketches: currentSketch.value == null
                          ? []
                          : [currentSketch.value!]),
                ),
              ),
            );
          },
        ),
      )
    ]);
  }
}

class SketchPainter extends CustomPainter {
  final List<Sketch> sketches;

  SketchPainter({required this.sketches});

  @override
  void paint(Canvas canvas, Size size) {
    for (Sketch sketch in sketches) {
      final points = sketch.points;

      if (points.isEmpty) return;

      final path = Path();

      if (points.length < 2) {
        // If the path only has one line, draw a dot.
        path.addOval(
          Rect.fromCircle(
            center: Offset(points[0].dx, points[0].dy),
            radius: 1,
          ),
        );
      }

      Paint paint = Paint()
        ..color = sketch.color
        ..strokeCap = StrokeCap.round
        ..style = sketch.filled ? PaintingStyle.fill : PaintingStyle.stroke
        ..strokeWidth = sketch.size;

      Offset firstPoint = points.first;
      Offset lastPoint = points.last;
      path.moveTo(firstPoint.dx, firstPoint.dy);

      for (int i = 1; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];

        path.quadraticBezierTo(
            p0.dx, p0.dy, (p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      }
      if (sketch.type == SketchType.pencil) {
        canvas.drawPath(path, paint);
      } else if (sketch.type == SketchType.line) {
        canvas.drawLine(firstPoint, lastPoint, paint);
      } else if (sketch.type == SketchType.square) {
        canvas.drawRect(Rect.fromPoints(firstPoint, lastPoint), paint);
      } else if (sketch.type == SketchType.circle) {
        canvas.drawOval(Rect.fromPoints(firstPoint, lastPoint), paint);
      } else if (sketch.type == SketchType.polygon) {
        Path polygonPath = Path();
        int sides = sketch.sides;
        var angle = (pi * 2) /
            sides; //because there are 2pi radians in a circle = 360 degrees
        final radius = (firstPoint - lastPoint).distance / 2;
        Offset centerPoint = (firstPoint / 2) + (lastPoint / 2);

        double radian = 0;
        Offset startPoint = Offset(centerPoint.dx + radius * cos(radian),
            centerPoint.dy + radius * sin(radian));

        polygonPath.moveTo(startPoint.dx, startPoint.dy);

        for (int i = 0; i < sides; i++) {
          polygonPath.lineTo(
              centerPoint.dx + radius * cos(radian + angle * i),
              centerPoint.dy +
                  radius *
                      sin(radian +
                          angle *
                              i)); //centerPoint + radius * cos(radian) is the formula for finding the x coordinate of a point on a circle
        }

        polygonPath.close();
        canvas.drawPath(polygonPath, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SketchPainter oldDelegate) {
    return oldDelegate.sketches != sketches;
  }
}
