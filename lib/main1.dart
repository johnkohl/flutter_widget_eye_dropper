import 'package:flutter/material.dart';
import 'package:pixel_color_image/pixel_color_image.dart';
import 'dart:async'; // Import the async library for Timer

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final PixelColorRef ref = PixelColorRef();
  Timer? _throttleTimer;
  int _lastX = -1;
  int _lastY = -1;
  Color _lastColor = Colors.transparent;

  void _updateColorInfo(int x, int y, Color color) {
    // Check if position or color has changed
    if (x != _lastX || y != _lastY || color != _lastColor) {
      // Update the last values
      _lastX = x;
      _lastY = y;
      _lastColor = color;

      // Extract RGBA values
      int red = color.red;
      int green = color.green;
      int blue = color.blue;
      double opacity = color.opacity;

      // Print color values
      debugPrint(
          'Hover x: $x, y: $y, Color - R:$red, G:$green, B:$blue, Opacity:$opacity');
    }
  }

  void onHover(int x, int y, Color color) {
    if (_throttleTimer == null || !_throttleTimer!.isActive) {
      _throttleTimer = Timer(const Duration(milliseconds: 1000), () {
        _updateColorInfo(x, y, color);
      });
    }
  }

  // Function to handle tap event
  void onTap(int x, int y, Color color) async {
      // Update the last values
      _lastX = x;
      _lastY = y;
      _lastColor = color;
      // Extract RGBA values
      int red = color.red;
      int green = color.green;
      int blue = color.blue;
      double opacity = color.opacity;
      debugPrint(
          'Tap x: $x, y: $y, Color - R:$red, G:$green, B:$blue, Opacity:$opacity');
  }

  @override
  void dispose() {
    _throttleTimer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            PixelColorPreview(
              ref: ref,
            ),
            Expanded(  // Make sure the image takes up the remaining space
              child: AspectRatio(
                aspectRatio: 16 / 9,  // Set the aspect ratio as per your image
                child: FittedBox(
                  fit: BoxFit.contain,  // Ensures the entire image is visible
                  child: PixelColor.assetImage(
                    path: 'assets/sample_image.jpeg',
                    onHover: onHover,
                    onTap: onTap,
                    ref: ref,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
