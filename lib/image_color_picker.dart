import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:pixel_color_image/pixel_color_image.dart';

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
    print('\n');

    try {
      double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
      print('Device Pixel Ratio: $devicePixelRatio');

      RenderBox box = context.findRenderObject() as RenderBox;
      final rawGlobalPosition = details.globalPosition;
      print(
          'Raw Tap Coordinates: $rawGlobalPosition'); // Log raw tap coordinates

      final offset = box.globalToLocal(rawGlobalPosition);
      print(
          'Transformed Coordinates (RelativeToBox): $offset'); // Log transformed coordinates

      double scaleFactor, offsetX, offsetY;
      Size boxSize = box.size;
      print('Window (RenderBox) Dimensions: $boxSize');

      ByteData byteData = await rootBundle.load('assets/sample_image.jpeg');
      final list = byteData.buffer.asUint8List();
      final codec = await ui.instantiateImageCodec(list);
      final frame = await codec.getNextFrame();
      final imageSize =
          Size(frame.image.width.toDouble(), frame.image.height.toDouble());
      print('Actual Image Dimensions: $imageSize');

      if ((boxSize.width / boxSize.height) >
          (imageSize.width / imageSize.height)) {
        // Letterboxing
        scaleFactor = boxSize.height / imageSize.height;
        double scaledWidth = imageSize.width * scaleFactor;
        offsetX = (boxSize.width - scaledWidth) / 2;
        offsetY = 0;
        print('Letterboxing: OffsetX=$offsetX, ScaleFactor=$scaleFactor');
      } else {
        // Pillarboxing
        scaleFactor = boxSize.width / imageSize.width;
        double scaledHeight = imageSize.height * scaleFactor;
        offsetX = 0;
        offsetY = (boxSize.height - scaledHeight) / 2;
        print('Pillarboxing: OffsetY=$offsetY, ScaleFactor=$scaleFactor');
      }

      Offset adjustedOffset = Offset(
        ((offset.dx - offsetX) / scaleFactor) / devicePixelRatio,
        ((offset.dy - offsetY) / scaleFactor) / devicePixelRatio,
      );
      print('Adjusted Tap Coordinates for High-DPI: $adjustedOffset');

      if (adjustedOffset.dx < 0 ||
          adjustedOffset.dx >= imageSize.width ||
          adjustedOffset.dy < 0 ||
          adjustedOffset.dy >= imageSize.height) {
        print("Tap coordinates are out of image bounds");
        return;
      }

      final pixel = await getImagePixel(adjustedOffset);

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

  // Load the image
  ByteData byteData = await rootBundle.load('assets/sample_image.jpeg');
  Uint8List values = byteData.buffer.asUint8List();
  ui.Codec codec = await ui.instantiateImageCodec(values);
  ui.FrameInfo fi = await codec.getNextFrame();

  // Get image dimensions
  int pixelWidth = fi.image.width;
  int pixelHeight = fi.image.height;

  // Create a picture recorder
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  // Draw the image onto the canvas
  final paint = Paint();
  canvas.drawImage(fi.image, Offset.zero, paint);

  // End recording the canvas
  final picture = recorder.endRecording();
  final img = await picture.toImage(pixelWidth, pixelHeight);

  // Get the pixel data from the canvas
  final canvasByteData = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (canvasByteData == null) {
    print("Failed to get byte data from canvas");
    return Colors.transparent; // or handle the null case as needed
  }
  final buffer = canvasByteData.buffer;

  // Calculate the pixel index
  int pixelX = math.min(globalPosition.dx.round(), pixelWidth - 1);
  int pixelY = math.min(globalPosition.dy.round(), pixelHeight - 1);

  // Ensure the pixel coordinates are within the bounds
  if (pixelX < 0 || pixelX >= pixelWidth || pixelY < 0 || pixelY >= pixelHeight) {
    print("Pixel coordinates are out of image bounds");
    return Colors.transparent;
  }

  int pixelIndex = (pixelY * pixelWidth + pixelX) * 4;

  // Get the pixel color
  final rgba = buffer.asUint32List(pixelIndex, 1);

  return Color(rgba[0]);
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
