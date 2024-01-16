import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_draw_appp/TestLib.dart';
import 'package:flutter_draw_appp/view/drawing_page.dart';

void main() {
  debugRepaintRainbowEnabled = true;
  runApp(const MainApp());
}

const Color kCanvasColor = Color(0xfff2f3f7);

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Container(
          color: Colors.white,
          width: double.infinity,
          height: double.infinity,
          child: const DrawingPage()),
    );
  }
}
