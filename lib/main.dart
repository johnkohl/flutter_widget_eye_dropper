import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Widget Demo',
      home: Scaffold(
        body: Center(
          child: NewCustomWidget(
            imageURL: 'assets/sample_image.jpeg', // Replace with your image URL
          ),
        ),
      ),
    );
  }
}

class NewCustomWidget extends StatefulWidget {
  const NewCustomWidget({
    super.key,
    this.width,
    this.height,
    required this.imageURL,
  });

  final double? width;
  final double? height;
  final String imageURL;

  @override
  State<NewCustomWidget> createState() => _NewCustomWidgetState();
}

class _NewCustomWidgetState extends State<NewCustomWidget> {
  Color _selectedColor = Colors.transparent;
  List<Color> _sampledColors = [];
  GlobalKey _imageKey = GlobalKey();

  void _sampleColors(Offset position) async {
    final RenderBox renderBox =
        _imageKey.currentContext!.findRenderObject() as RenderBox;
    final Size size = renderBox.size;

    // Capture a screenshot of the rendered image
    final screenshot = await _captureScreenshot(renderBox);

    // Calculate the relative position within the screenshot
    final dx = position.dx / size.width;
    final dy = position.dy / size.height;

    // Sample colors from the screenshot
    final colors = await _sampleImageColors(screenshot, dx, dy);

    // Calculate the average color
    final avgColor = _calculateAverageColor(colors);

    // Update the selected color and sampled colors
    setState(() {
      _selectedColor = avgColor;
      _sampledColors = colors;
    });
  }

  Future<ui.Image> _captureScreenshot(RenderBox renderBox) async {
    final RenderRepaintBoundary boundary = renderBox as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage();
    return image;
  }

  Color _calculateAverageColor(List<Color> colors) {
    int r = 0, g = 0, b = 0;
    for (final color in colors) {
      r += color.red;
      g += color.green;
      b += color.blue;
    }
    r ~/= colors.length;
    g ~/= colors.length;
    b ~/= colors.length;
    return Color.fromRGBO(r, g, b, 1);
  }

  Future<List<Color>> _sampleImageColors(
      ui.Image image, double dx, double dy) async {
    final completer = Completer<List<Color>>();

    // Calculate the pixel coordinates based on the relative position
    final width = image.width;
    final height = image.height;
    final x = (dx * width).floor();
    final y = (dy * height).floor();

    // Convert the ui.Image to a ByteData
    final byteData = await image.toByteData();
    final bytes = byteData?.buffer.asUint8List() ?? Uint8List(0);

    // Calculate the pixel index based on the coordinates and image width
    final pixelIndex = (y * width + x) * 4;

    // Extract the color values from the pixel bytes
    final r = bytes[pixelIndex];
    final g = bytes[pixelIndex + 1];
    final b = bytes[pixelIndex + 2];

    // Sample colors from the target pixel and its neighbors
    final colors = [
      Color.fromRGBO(r, g, b, 1),
      _sampleNeighborColor(bytes, x - 1, y, width),
      _sampleNeighborColor(bytes, x + 1, y, width),
      _sampleNeighborColor(bytes, x, y - 1, width),
      _sampleNeighborColor(bytes, x, y + 1, width),
    ];

    completer.complete(colors);
    return completer.future;
  }

  Color _sampleNeighborColor(Uint8List bytes, int x, int y, int width) {
    if (x < 0 || x >= width || y < 0 || y >= bytes.length ~/ (width * 4)) {
      return Color.fromRGBO(0, 0, 0, 1);
    }
    final pixelIndex = (y * width + x) * 4;
    final r = bytes[pixelIndex];
    final g = bytes[pixelIndex + 1];
    final b = bytes[pixelIndex + 2];
    return Color.fromRGBO(r, g, b, 1);
  }

  @override
  Widget build(BuildContext context) {
    return
    Column(
      children: [
        Expanded(
          flex: 5,
          child: GestureDetector(
            onTapDown: (details) {
              final position = details.localPosition;
              _sampleColors(position);
            },
            child: RepaintBoundary(
              key: _imageKey,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return FittedBox(
                    fit: BoxFit.contain,
                    child: Image.network(
                      widget.imageURL,
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text('Failed to load image'),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  String getHexColor() {
    return '#${_selectedColor.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }
}
