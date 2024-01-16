import 'package:flutter/material.dart';
import 'package:flutter_draw_appp/main.dart';
import 'package:flutter_draw_appp/view/models/drawing_mode.dart';

class Sketch {
  final List<Offset> points;
  final Color color;
  final double size;
  final SketchType type;
  final bool filled;
  final int sides;
  late String deviceName;

  Sketch(
      {required this.points,
      required this.color,
      required this.size,
      this.deviceName = '',
      this.type = SketchType.pencil,
      this.filled = false,
      this.sides = 3}) {
    deviceName = deviceData['product'];
  }

  //Convert to json
  Map<String, dynamic> toJson() => {
        'points': points.map((e) => {'dx': e.dx, 'dy': e.dy}).toList(),
        'color': color.toHex(),
        'size': size,
        'type': type.toShortString(),
        'filled': filled,
        'sides': sides,
        'deviceName': deviceName,
      };

  //Convert from json
  factory Sketch.fromJson(Map<String, dynamic> json) => Sketch(
      points: (json['points'] as List)
          .map((e) => Offset(double.parse(e['dx'].toString()),
              double.parse(e['dy'].toString())))
          .toList(),
      color: (json['color'] as String).toColor(),
      size: json['size'],
      type: (json['type'] as String).toSketchTypeEnum(),
      filled: json['filled'],
      sides: json['sides'],
      deviceName: json['deviceName']);

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

extension SketchTypeX on SketchType {
  String toShortString() {
    return toString().split('.').last;
  }
}

extension SketchTypeExtension on String {
  toSketchTypeEnum() =>
      SketchType.values.firstWhere((e) => e.toString() == 'SketchType.$this');
}

extension ColorExtension on String {
  Color toColor() {
    var hexColor = replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    if (hexColor.length == 8) {
      return Color(int.parse('0x$hexColor'));
    } else {
      return Colors.black;
    }
  }
}

extension ColorExtensionX on Color {
  String toHex() => '#${value.toRadixString(16).substring(2, 8)}';
}
