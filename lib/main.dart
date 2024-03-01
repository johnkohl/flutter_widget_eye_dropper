import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
  double _mouseX = 0;
  double _mouseY = 0;
  double _imgPOSX = 0;
  double _imgPOSY = 0;

  double _xInImage = 0;
  double _yInImage = 0;

  final _keyImage = GlobalKey();

  void _updateLocation(PointerEvent details) {
    setState(() {
      // find where the parent container is for the image
      RenderBox msRgn =
          _keyImage.currentContext!.findRenderObject() as RenderBox;

      final imgPostion = msRgn.localToGlobal(Offset.zero);
      _imgPOSX = imgPostion.dx + .5; // .5 for the border maybe?
      _imgPOSY = imgPostion.dy;
      _mouseX = details.position.dx;
      _mouseY = details.position.dy;

      // subtract where the parent container position from the mouse position
      // to get the mouse position in the image
      _xInImage = _mouseX - _imgPOSX;
      _yInImage = _mouseY - _imgPOSY;
    });
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
            const Text(
              'The X,Y coordinates of the mouse are :',
            ),
            Text(
              '$_mouseX / $_mouseY',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const Text(
              'The X,Y coordinates of the region are :',
            ),
            Text(
              '$_imgPOSX / $_imgPOSY',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const Text(
              'The calculated X,Y coordinates inside the image are :',
            ),
            Text(
              '$_xInImage / $_yInImage',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Flexible(
              key: _keyImage,
              child: MouseRegion(
                onHover: _updateLocation,
                child: Image.asset('assets/sample_image.jpeg'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}