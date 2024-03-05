import 'package:flutter/material.dart';
import 'package:pick_color/pick_color.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ColorPickerScreen(),
    );
  }
}

class ColorPickerScreen extends StatefulWidget {
  @override
  _ColorPickerScreenState createState() => _ColorPickerScreenState();
}

class _ColorPickerScreenState extends State<ColorPickerScreen> {
  Image image = Image.asset(
    "assets/sample_image.jpeg",
    fit: BoxFit.contain, // BoxFit.contain to ensure the image is always fully visible
  );
  Color? color;
  PickerResponse? userResponse;

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size; // Get the screen size

    return SafeArea(
      child: Scaffold(
          body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                      color: userResponse?.selectionColor ?? Colors.red,
                      border: Border.all(color: Colors.black, width: 0),
                      borderRadius: BorderRadius.circular(0)),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text("${userResponse?.hexCode ?? ""}",
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Expanded(
            child: AspectRatio(
              aspectRatio: screenSize.width / screenSize.height, // Set aspect ratio based on screen size
              child: ColorPicker(
                child: image,
                showMarker: false,
                onChanged: (response) {
                  setState(() {
                    userResponse = response;
                    this.color = response.selectionColor;
                  });
                }),
            ),
          ),
        ],
      )),
    );
  }
}