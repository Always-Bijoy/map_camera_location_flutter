import 'package:flutter/material.dart';
import 'package:map_camera_flutter/map_camera_flutter.dart';
import 'package:permission_handler/permission_handler.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp( MyApp(camera: firstCamera,));
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
      home:  MyHomePage(title: 'Flutter Demo Home Page',camera: camera,),
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

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // If location services are disabled, show an error message or request the user to enable them
      throw Exception('Location services are disabled.');
    }
    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // If location permission is denied, request it
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // If location permission is still denied, show an error message or redirect the user to the app settings
        throw Exception('Location permissions are denied');
      }
    }

    // Check if location permission is permanently denied
    if (permission == LocationPermission.deniedForever) {
      // Show an error message or redirect the user to the app settings to enable location permissions
      throw Exception('Location permissions are permanently denied, we cannot request permissions.');
    }

    // Get the current position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _determinePosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: MapCameraLocation(camera: widget.camera, onImageCaptured: (ImageAndLocationData data){
        print('Captured image path: ${data.imagePath}');
        print('Latitude: ${data.latitude}');
        print('Longitude: ${data.longitude}');
        print('Location name: ${data.locationName}');
        print('Sublocation: ${data.subLocation}');
      },)
    );
  }
}
