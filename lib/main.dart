import 'package:flutter/material.dart';
import 'package:pixel_color_image/pixel_color_image.dart';

/// Called while Hovering
void onHover(int x, int y, Color color) async {
  debugPrint('Hover x: $x, y: $y, color: $color');
}

/// Called when tap
void onTap(int x, int y, Color color) async {
  debugPrint('Tap x: $x, y: $y, color: $color');
}

/// Reference for Preview
final ref = PixelColorRef();

/// main
void main() async {
  // Image
  final pixelColorImage = PixelColor.assetImage(
    path: 'assets/sample_image.jpeg',
    onHover: onHover,
    onTap: onTap,
    ref: ref,
  );

  // Color Preview
  final pixelColorPreview = PixelColorPreview(
    ref: ref,
  );

  // App
  final app = MaterialApp(
    home: Scaffold(
      body: Column(
        children: [
          pixelColorPreview, // color preview
          Expanded(
            child: FittedBox(
              fit: BoxFit.contain,
              child: pixelColorImage, // image
            ),
          ),
        ],
      ),
    ),
  );

  // Run App
  runApp(app);
}