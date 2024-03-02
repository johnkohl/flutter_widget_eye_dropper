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
      home: ImagePickerScreen(),
    );
  }
}

class ImagePickerScreen extends StatefulWidget {
  @override
  _ImagePickerScreenState createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  Image image = Image.asset(
    "assets/sample_image.jpeg",
    height: 300,
  );
  Color? color;
  PickerResponse? userResponse;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(0),
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
                Text("${userResponse?.hexCode ?? ""}",
                    style: const TextStyle(
                        color: Color.fromARGB(255, 43, 38, 38),
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          ColorPicker(
              child: image,
              showMarker: true,
              onChanged: (response) {
                setState(() {
                  userResponse = response;
                  this.color = response.selectionColor;
                });
              }),

          // ${userResponse?.hexCode ?? ""}
        ],
      )),
    );
  }
}
