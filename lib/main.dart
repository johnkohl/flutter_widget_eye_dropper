import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:pixel_color_image/pixel_color_image.dart';

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

  // Function to handle hover event
  void onHover(int x, int y, Color color) {
    // Extract RGBA values
    int red = color.red;
    int green = color.green;
    int blue = color.blue;
    double opacity = color.opacity; // Alpha value as a fraction of 1

    // Print color values
    debugPrint('Hover x: $x, y: $y, Color - R:$red, G:$green, B:$blue, Opacity:$opacity');
  }

  // Function to handle tap event
  void onTap(int x, int y, Color color) async {
    debugPrint('Tap x: $x, y: $y, color: $color');
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
            PixelColor.assetImage(
              path: 'assets/sample_image.jpeg',
              onHover: onHover,
              onTap: onTap,
              ref: ref,
            ),
          ],
        ),
      ),
    );
  }
}
