import 'package:flutter/material.dart';
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
        appBar: AppBar(
          title: Text('Custom Widget Demo'),
        ),
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

  void _sampleColors(Offset position) async {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    // Calculate the relative position within the image
    final dx = position.dx / size.width;
    final dy = position.dy / size.height;
    // Sample colors from the image
    final colors = await _sampleImageColors(widget.imageURL, dx, dy);
    // Calculate the average color
    final avgColor = _calculateAverageColor(colors);
    // Update the selected color
    setState(() {
      _selectedColor = avgColor;
    });
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
      String imageUrl, double dx, double dy) async {
    final completer = Completer<List<Color>>();
    // Load the image using Image.network
    final imageProvider = Image.network(imageUrl).image;
    // Resolve the image and get its dimensions
    final imageStream = imageProvider.resolve(ImageConfiguration());
    final listener = ImageStreamListener((ImageInfo info, bool _) async {
      // Convert the image to a ui.Image
      final uiImage = info.image;
      // Calculate the pixel coordinates based on the relative position
      final width = uiImage.width;
      final height = uiImage.height;
      final x = (dx * width).floor();
      final y = (dy * height).floor();
      // Convert the ui.Image to a ByteData
      final byteData = await uiImage.toByteData();
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
    });
    imageStream.addListener(listener);
    final colors = await completer.future;
    imageStream.removeListener(listener);
    return colors;
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
  return Column(
    children: [
      Expanded( // This Expanded widget ensures that the color display takes up minimal necessary space
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '#${_selectedColor.value.toRadixString(16).padLeft(8, '0').substring(2)}',
              ),
              SizedBox(width: 10),
              Container(
                width: 20,
                height: 20,
                color: _selectedColor,
              ),
            ],
          ),
        ),
      ),
      Expanded( // This Expanded widget allows the image to take up the rest of the available space
        flex: 5, // Adjust the flex factor if needed to allocate more space to the image
        child: GestureDetector(
          onTapDown: (details) {
            final position = details.localPosition;
            _sampleColors(position);
          },
          child: FittedBox(
            fit: BoxFit.contain,
            child: Image.network(
              widget.imageURL,
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