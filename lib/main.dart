import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_draw_appp/view/drawing_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  debugRepaintRainbowEnabled = true;
  getDeviceInfo();
  runApp(const MainApp());
}

final deviceInfoPlugin = DeviceInfoPlugin();
late final Map<String, dynamic> deviceData;

void getDeviceInfo() async {
  final deviceInfo = await deviceInfoPlugin.deviceInfo;
  deviceData = deviceInfo.data;
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
