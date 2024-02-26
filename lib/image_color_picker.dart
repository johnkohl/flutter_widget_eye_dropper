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
  Offset? tapPosition; // Add this variable to hold the tap position

  // Method to pick color from image
  void pickColor(TapUpDetails details, BuildContext context) async {
    try {
      RenderBox box = context.findRenderObject() as RenderBox;
      final offset = box.globalToLocal(details.globalPosition);
      final pixel = await getImagePixel(offset);

      setState(() {
        pickedColor = pixel;
        tapPosition = offset; // Update the tap position
        print('Picked color: ${pickedColor.toHex()}');
      });
    } catch (e) {
      print('Error picking color: $e');
    }
  }

  // Method to get pixel color from image
  Future<Color> getImagePixel(Offset globalPosition) async {
    ByteData byteData = await rootBundle.load('assets/sample_image.jpeg');
    Uint8List values = byteData.buffer.asUint8List();
    ui.Codec codec = await ui.instantiateImageCodec(values);
    ui.FrameInfo fi = await codec.getNextFrame();

    if (globalPosition.dx < 0 ||
        globalPosition.dy < 0 ||
        globalPosition.dx >= fi.image.width ||
        globalPosition.dy >= fi.image.height) {
      return Colors.transparent; // Return transparent color if out of bounds
    }

    int pixelWidth = fi.image.width;
    int pixelX = globalPosition.dx.round();
    int pixelY = globalPosition.dy.round();
    int pixelIndex = (pixelY * pixelWidth + pixelX) * 4;

    if (pixelIndex >= values.length - 4) { // Check if the index is within the array
      return Colors.transparent;
    }

    int r = values[pixelIndex + 0];
    int g = values[pixelIndex + 1];
    int b = values[pixelIndex + 2];
    int a = values[pixelIndex + 3];

    return Color.fromARGB(a, r, g, b);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTapUp: (details) {
          pickColor(details, context);
        },
        child: CustomPaint(
          painter: TapPositionPainter(tapPosition),
          child: Image.asset('assets/sample_image.jpeg'),
        ),
      ),
    );
  }
}

class TapPositionPainter extends CustomPainter {
  final Offset? tapPosition;

  TapPositionPainter(this.tapPosition);

  @override
  void paint(Canvas canvas, Size size) {
    if (tapPosition != null) {
      canvas.drawCircle(tapPosition!, 10, Paint()..color = Colors.red);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

extension ColorExtension on Color {
  String toHex() =>
      '#${red.toRadixString(16).padLeft(2, '0')}${green.toRadixString(16).padLeft(2, '0')}${blue.toRadixString(16).padLeft(2, '0')}';
}
