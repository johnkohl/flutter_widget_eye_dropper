import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

class ImageColorPicker extends StatefulWidget {
  const ImageColorPicker({super.key});

  @override
  _ImageColorPickerState createState() => _ImageColorPickerState();
}

class _ImageColorPickerState extends State<ImageColorPicker> {
  // This will hold the color value we pick
  Color pickedColor = Colors.transparent;

  // Method to pick color from image
  void pickColor(TapUpDetails details, BuildContext context) async {
    try {
      RenderBox box = context.findRenderObject() as RenderBox;
      final offset = box.globalToLocal(details.globalPosition);
      final pixel = await getImagePixel(offset);

      setState(() {
        pickedColor = pixel;
        // Print the picked color value to console
        print('Picked color: ${pickedColor.toHex()}');
      });
    } catch (e) {
      print('Error picking color: $e');
    }
  }

  // Method to get pixel color from image
  Future<Color> getImagePixel(Offset globalPosition) async {
    ByteData byteData = await rootBundle.load('assets/sample_image.jpeg');
    Uint8List values =
        byteData.buffer.asUint8List(); // Ensure 'values' is Uint8List
    ui.Codec codec =
        await ui.instantiateImageCodec(values); // Pass 'values' directly
    ui.FrameInfo fi = await codec.getNextFrame();

    int pixelWidth = fi.image.width;
    int pixelX = globalPosition.dx.round();
    int pixelY = globalPosition.dy.round();
    int pixelIndex = (pixelY * pixelWidth + pixelX) * 4;

    int r = values[pixelIndex + 0];
    int g = values[pixelIndex + 1];
    int b = values[pixelIndex + 2];
    int a = values[pixelIndex + 3];

    return Color.fromARGB(a, r, g, b);
  }

  // Helper method to load image
  Future<ui.Image> loadImage(ByteData data) async {
    final list = data.buffer.asUint8List();
    final codec = await ui.instantiateImageCodec(list);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  // Helper method to convert color format
  int abgrToArgb(int pixel) {
    int r = (pixel >> 16) & 0xFF;
    int b = (pixel >> 0) & 0xFF;
    return (pixel & 0xFF00FF00) | (b << 16) | r;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTapUp: (details) {
          pickColor(details, context);
        },
        child: Image.asset('assets/sample_image.jpeg'),
      ),
    );
  }
}

extension ColorExtension on Color {
  // Helper method to convert Color object to hex string
  String toHex() =>
      '#${red.toRadixString(16).padLeft(2, '0')}${green.toRadixString(16).padLeft(2, '0')}${blue.toRadixString(16).padLeft(2, '0')}';
}
