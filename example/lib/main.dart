import 'package:flutter/material.dart';
import 'package:map_camera_flutter/map_camera_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(MyApp(
    camera: firstCamera,
  ));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;
  const MyApp({super.key, required this.camera});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(
        title: 'Camera With Map Location',
        camera: camera,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.camera});
  final CameraDescription camera;

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: MapCameraLocation(
          camera: widget.camera,
          onImageCaptured: (ImageAndLocationData data) {
            print('Captured image path: ${data.imagePath}');
            print('Latitude: ${data.latitude}');
            print('Longitude: ${data.longitude}');
            print('Location name: ${data.locationName}');
            print('Sublocation: ${data.subLocation}');
          },
        ));
  }
}
