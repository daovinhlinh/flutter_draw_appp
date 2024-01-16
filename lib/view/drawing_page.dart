import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import 'package:flutter_draw_appp/main.dart';
import 'package:flutter_draw_appp/view/models/sketch.dart';
import 'package:flutter_draw_appp/view/widgets/side_bar.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'drawing_canvas/drawing_canvas.dart';
import 'models/drawing_mode.dart';

class DrawingPage extends HookWidget {
  const DrawingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedColor = useState(Colors.black);
    final strokeSize = useState<double>(10);
    final eraserSize = useState<double>(30);
    final drawingMode = useState(DrawingMode.pencil);
    final filled = useState<bool>(false);
    final polygonSides = useState<int>(3);
    final backgroundImage = useState<Image?>(null);

    final canvasGlobalKey = GlobalKey();

    ValueNotifier<Sketch?> currentSketch = useState<Sketch?>(null);
    ValueNotifier<List<Sketch>> allSketches = useState<List<Sketch>>(
        List.generate(
            200,
            (index) => Sketch(
                points: List.generate(
                    20,
                    (index) =>
                        Offset(index.toDouble() * 10, index.toDouble() * 10)),
                color: Colors.black,
                size: 3)));

    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 150),
      initialValue: 1,
    );

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              color: kCanvasColor,
              width: double.maxFinite,
              height: double.maxFinite,
              child: DrawingCanvas(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                drawingMode: drawingMode,
                selectedColor: selectedColor,
                strokeSize: strokeSize,
                eraserSize: eraserSize,
                sideBarController: animationController,
                currentSketch: currentSketch,
                allSketches: allSketches,
                canvasGlobalKey: canvasGlobalKey,
                filled: filled,
                polygonSides: polygonSides,
                backgroundImage: backgroundImage,
              ),
            ),
            Positioned(
              top: kToolbarHeight + 10,
              // left: -5,
              child: Stack(
                children: [
                  // Positioned(
                  //     // width: double.maxFinite,
                  //     left: animationController.value == 1 ? 0 : -300,
                  //     child: GestureDetector(
                  //       onTap: () {
                  //         animationController.reverse();
                  //       },
                  //       child: Container(
                  //         width: double.maxFinite,
                  //         height: double.maxFinite,
                  //         color: Colors.black.withOpacity(0.7),
                  //       ),
                  //     )),
                  SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(-1, 0),
                      end: Offset.zero,
                    ).animate(animationController),
                    child: SideBar(
                      drawingMode: drawingMode,
                      selectedColor: selectedColor,
                      strokeSize: strokeSize,
                      eraserSize: eraserSize,
                      currentSketch: currentSketch,
                      allSketches: allSketches,
                      canvasGlobalKey: canvasGlobalKey,
                      filled: filled,
                      polygonSides: polygonSides,
                      backgroundImage: backgroundImage,
                    ),
                  )
                ],
              ),
            ),
            _CustomAppBar(
              animationController: animationController,
            )
          ],
        ),
      ),
    );
  }
}

class _CustomAppBar extends StatelessWidget {
  final AnimationController animationController;

  const _CustomAppBar({Key? key, required this.animationController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kToolbarHeight,
      width: double.maxFinite,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                if (animationController.value == 0) {
                  animationController.forward();
                } else {
                  animationController.reverse();
                }
              },
              icon: const Icon(Icons.menu),
            ),
            const Text(
              'Let\'s Draw',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 19,
              ),
            ),
            const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
