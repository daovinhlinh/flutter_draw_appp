import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter_draw_appp/main.dart';
import 'package:flutter_draw_appp/view/models/drawing_mode.dart';
import 'package:flutter_draw_appp/view/models/sketch.dart';
import 'dart:math' show pi, sin, cos;

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

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
  final ValueNotifier<Sketch?> tempSketch;
  final ValueNotifier<List<Sketch>> allSketches;
  final AnimationController sideBarController;

  DrawingCanvas(
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
      required this.tempSketch,
      super.key});

  final IO.Socket socket = IO.io(
    'ws://10.0.2.2:3000',
    IO.OptionBuilder().setTransports(['websocket']).build(),
  )..connect();

  final currentSketchStream = StreamController<String>();
  final allSketchesStream = StreamController<List<Sketch>>();

//Animation can cause another widget repaint => RepaintBoundary separating child widget to its own layer
  final scale = useState<double>(1.0);
  void onPointerUp(_) {
    // print("pointer")
    // allSketches.value = [
    //   ...allSketches.value,
    //   currentSketch.value!,
    // ];

    final newAllSketches = List<Sketch>.from(allSketches.value)
      ..add(currentSketch.value!);
    print(newAllSketches.length);
    allSketches.value = newAllSketches;
    // tempSketch.value = currentSketch.value;

    socket.emit('allSketches', jsonEncode(currentSketch.value?.toJson()));
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

    // socket.emit('allSketches',
    //     jsonEncode(allSketches.value.map((e) => e.toJson()).toList()));
  }

  @override
  Widget build(BuildContext context) {
    socket.onConnect((_) {
      print('connect');
    });

    print(scale.value);
    // socket.on('currentSketch', (data) => currentSketchStream.sink.add(data)
    // );
    socket.on('allSketches', (data) {
      if (data == null) return;
      List sketchesMap = jsonDecode(data);
      // print("sketchmap");
      // List<Sketch> sketches = List.empty(growable: true);

      if (sketchesMap.isNotEmpty) {
        final sketches = sketchesMap.where((json) {
          final sketch = jsonDecode(json);
          // print(sketch);
          // return sketch['deviceName'] != deviceData['product'];
          return true;
        }).map((json) {
          return Sketch.fromJson(jsonDecode(json) as Map<String, dynamic>);
        }).toList();
        allSketchesStream.sink.add(sketches);
      }
    });
    print(width);
    return GestureDetector(
      onScaleUpdate: (ScaleUpdateDetails details) {
        //limit scale to 0.5 - 2
        scale.value =
            scale.value * details.scale > 0.5 && scale.value * details.scale < 2
                ? scale.value * details.scale
                : scale.value;

        // You can apply your custom drawing logic here using the _scale factor.
        // For example, you might adjust the size of shapes drawn on the canvas.
      },
      child: Stack(alignment: Alignment.center, children: [
        // Container(
        //   width: (width + 20) * scale.value,
        //   height: (height + 20) * scale.value,
        //   color: Colors.red,
        // ),
        // RepaintBoundary(
        //   child: CustomPaint(
        //     foregroundPainter: SketchPainter(
        //         sketches: tempSketch.value != null ? [tempSketch.value!] : []),
        //   ),
        // ),
        RepaintBoundary(
          child: CustomPaint(
            painter: SketchPainter(
              sketches: allSketches.value,
            ),
          ),
        ),
        // StreamBuilder(
        //     stream: allSketchesStream.stream,
        //     builder: (context, snapshot) {
        //       // List<Sketch> sketches = List.empty(growable: true);
        //       // List sketchesMap = List.empty(growable: true);
        //       // if (snapshot.hasData) {
        //       //   sketchesMap = jsonDecode(snapshot.data!);
        //       //   sketches = sketchesMap
        //       //       .map((json) => Sketch.fromJson(json as Map<String, dynamic>))
        //       //       .toList();
        //       //   // tempSketch.value = [];
        //       // }
        //       // print(snapshot.data);
        //       return RepaintBoundary(
        //         key: canvasGlobalKey,
        //         child: SizedBox(
        //           height: height,
        //           width: width,
        //           child: CustomPaint(
        //             // isComplex: true,
        //             // willChange: false,
        //             painter: SketchPainter(
        //                 sketches: snapshot.data ?? [],
        //                 scaleFactor: scale.value),
        //           ),
        //         ),
        //       );
        //     }),
        // StreamBuilder(
        //     stream: currentSketchStream.stream,
        //     builder: (context, snapshot) {
        //       Sketch? sketch;
        //       Map<String, dynamic>? sketchMap;

        //       if (snapshot.hasData) {
        //         sketchMap = jsonDecode(snapshot.data!);
        //       }

        //       if (sketchMap != null) {
        //         sketch = Sketch.fromJson(sketchMap);
        //       }

        //       return Listener(
        //         behavior: HitTestBehavior.opaque,
        //         onPointerDown: (details) {
        //           final box = context.findRenderObject() as RenderBox;
        //           final offset = box.globalToLocal(details.position);
        //           currentSketch.value = Sketch(
        //               points: [offset],
        //               color: drawingMode.value == DrawingMode.eraser
        //                   ? kCanvasColor
        //                   : selectedColor.value,
        //               size: drawingMode.value == DrawingMode.eraser
        //                   ? eraserSize.value
        //                   : strokeSize.value,
        //               type: () {
        //                 switch (drawingMode.value) {
        //                   case DrawingMode.pencil:
        //                     return SketchType.pencil;
        //                   case DrawingMode.line:
        //                     return SketchType.line;
        //                   case DrawingMode.square:
        //                     return SketchType.square;
        //                   case DrawingMode.circle:
        //                     return SketchType.circle;
        //                   case DrawingMode.polygon:
        //                     return SketchType.polygon;
        //                   default:
        //                     return SketchType.pencil;
        //                 }
        //               }(),
        //               sides: polygonSides.value,
        //               filled: filled.value &&
        //                   drawingMode.value != DrawingMode.pencil &&
        //                   drawingMode.value != DrawingMode.eraser);
        //         },
        //         onPointerUp: onPointerUp,
        //         onPointerMove: (details) {
        //           final box = context.findRenderObject() as RenderBox;
        //           final offset = box.globalToLocal(details.position);

        //           final point =
        //               List<Offset>.from(currentSketch.value?.points ?? [])
        //                 ..add(offset);

        //           currentSketch.value = Sketch(
        //             points: point,
        //             color: drawingMode.value == DrawingMode.eraser
        //                 ? kCanvasColor
        //                 : selectedColor.value,
        //             size: drawingMode.value == DrawingMode.eraser
        //                 ? eraserSize.value
        //                 : strokeSize.value,
        //             type: () {
        //               switch (drawingMode.value) {
        //                 case DrawingMode.pencil:
        //                   return SketchType.pencil;
        //                 case DrawingMode.line:
        //                   return SketchType.line;
        //                 case DrawingMode.square:
        //                   return SketchType.square;
        //                 case DrawingMode.circle:
        //                   return SketchType.circle;
        //                 case DrawingMode.polygon:
        //                   return SketchType.polygon;
        //                 default:
        //                   return SketchType.pencil;
        //               }
        //             }(),
        //             filled: filled.value &&
        //                 drawingMode.value != DrawingMode.pencil &&
        //                 drawingMode.value != DrawingMode.eraser,
        //             sides: polygonSides.value,
        //           );
        //           socket.emit(
        //               'currentSketch', jsonEncode(currentSketch.value?.toJson()));
        //         },
        //         child: RepaintBoundary(
        //           child: SizedBox(
        //             height: height,
        //             width: width,
        //             child: CustomPaint(
        //               // isComplex: true,
        //               // willChange: false,
        //               foregroundPainter: SketchPainter(
        //                   sketches: sketch == null ? [] : [sketch!]),
        //             ),
        //           ),
        //         ),
        //       );
        //     })

        Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (details) {
            final box = context.findRenderObject() as RenderBox;
            final offset = box.globalToLocal(details.position);
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
                filled: filled.value);
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
              filled: filled.value,
              sides: polygonSides.value,
            );
            // socket.emit(
            //     'currentSketch', jsonEncode(currentSketch.value?.toJson()));
          },
          child: RepaintBoundary(
            child: Container(
              // color: Colors.red,
              height: height * scale.value,
              width: width * scale.value,
              child: CustomPaint(
                // isComplex: true,
                // willChange: false,

                painter: SketchPainter(
                    scaleFactor: scale.value,
                    sketches: currentSketch.value == null
                        ? []
                        : [currentSketch.value!]),
              ),
            ),
          ),
        )
      ]),
    );
  }
}

class SketchPainter extends CustomPainter {
  final List<Sketch> sketches;
  final double scaleFactor;
  SketchPainter({required this.sketches, this.scaleFactor = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    for (Sketch sketch in sketches) {
      final points = sketch.points;

      if (points.isEmpty) return;

      final path = Path();

      Paint paint = Paint()
        ..color = sketch.color
        ..strokeCap = StrokeCap.round
        ..style = sketch.filled ? PaintingStyle.fill : PaintingStyle.stroke
        ..strokeWidth = sketch.size;

      // canvas.scale(scaleFactor);

      if (points.length < 2) {
        paint.style = PaintingStyle.fill;
        // If the path only has one line, draw a dot.
        path.addOval(
          Rect.fromCircle(
            center: Offset(points[0].dx, points[0].dy),
            radius: sketch.size / 2,
          ),
        );
      }

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
