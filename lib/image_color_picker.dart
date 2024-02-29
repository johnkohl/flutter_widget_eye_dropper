import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'dart:math' as math;

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
      print('\n');

      double scaleFactor = await _calculateScaleFactor(context);

      RenderBox box = context.findRenderObject() as RenderBox;
      final rawGlobalPosition = details.globalPosition;
      print('Raw Tap Coordinates: $rawGlobalPosition'); // Log raw tap coordinates

      final offset = box.globalToLocal(rawGlobalPosition);
      print('Transformed Coordinates (RelativeToBox): $offset'); // Log transformed coordinates

      final scaledOffset = Offset(
        offset.dx / scaleFactor,
        offset.dy / scaleFactor,
      );
      print('Scaled Coordinates: $scaledOffset'); // Log final scaled coordinates

      final pixel = await getImagePixel(scaledOffset);

      setState(() {
        pickedColor = pixel;
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

    int pixelWidth = fi.image.width;
    int pixelX = math.min(globalPosition.dx.round(), pixelWidth - 1);
    int pixelY = math.min(globalPosition.dy.round(), fi.image.height - 1);
    int pixelIndex = (pixelY * pixelWidth + pixelX) * 4;

    int r = values[pixelIndex + 0];
    int g = values[pixelIndex + 1];
    int b = values[pixelIndex + 2];
    int a = values[pixelIndex + 3];

    print('Image Dimensions: $pixelWidth x ${fi.image.height}');
    print('Pixel Coordinates: $pixelX, $pixelY');

    return Color.fromARGB(a, r, g, b);
  }

  // Helper method to calculate the scale factor
  Future<double> _calculateScaleFactor(BuildContext context) async {
    RenderBox box = context.findRenderObject() as RenderBox;
    Size size = box.size; // Size of the image widget on the screen
    print('Window (RenderBox) Dimensions: $size');

    ByteData byteData = await rootBundle.load('assets/sample_image.jpeg');
    final list = byteData.buffer.asUint8List();
    final codec = await ui.instantiateImageCodec(list);
    final frame = await codec.getNextFrame();
    final imageSize = Size(
      frame.image.width.toDouble(),
      frame.image.height.toDouble(),
    ); // Actual size of the image
    print('Actual Image Dimensions: $imageSize');

    double scaleX = size.width / imageSize.width;
    double scaleY = size.height / imageSize.height;
    // print ('scaleX: $scaleX');
    // print ('scaleY: $scaleY');    
    double scaleFactor = math.min(scaleX, scaleY);
    print('Scale Factor: $scaleFactor');

    // Assuming the image is scaled uniformly
    return math.min(scaleX, scaleY);
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
