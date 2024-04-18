import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:latlong2/latlong.dart' as lat;
import 'package:map_camera_flutter/map_camera_flutter.dart';

///import 'package:your_app/map_camera_flutter.dart'; // Import the file where the MapCameraLocation widget is defined

/// ```
/// void main() {
/// final cameras = await availableCameras();
/// final firstCamera = cameras.first;
///   runApp(MyApp(camera: firstCamera));
/// }
///
/// class MyApp extends StatelessWidget {
/// final CameraDescription camera;
/// const MyApp({super.key, required this.camera});
///
///   @override
///   Widget build(BuildContext context) {
///     return MaterialApp(
///       home: CameraLocationScreen(camera: firstCamera),
///     );
///   }
/// }
///
/// class CameraLocationScreen extends StatelessWidget {
/// final CameraDescription camera;
/// const MyApp({super.key, required this.camera});
//   // Callback function to handle the captured image and location data
///   void handleImageAndLocationData(ImageAndLocationData data) {
//     // You can use the data here as needed
///     print('Image Path: ${data.imagePath}');
///     print('Latitude: ${data.latitude}');
///     print('Longitude: ${data.longitude}');
///     print('Location Name: ${data.locationName}');
///     print('SubLocation: ${data.subLocation}');
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     // Provide the CameraDescription and the handleImageAndLocationData callback function to the MapCameraLocation widget
///     return MapCameraLocation(
///       camera: camera, // YOUR_CAMERA_DESCRIPTION_OBJECT, // Replace YOUR_CAMERA_DESCRIPTION_OBJECT with your actual CameraDescription
///       onImageCaptured: handleImageAndLocationData,
///     );
///   }
/// }
/// ```

// Callback function type for capturing image and location data
typedef ImageAndLocationCallback = void Function(ImageAndLocationData data);

class MapCameraLocation extends StatefulWidget {
  final CameraDescription camera;
  final ImageAndLocationCallback? onImageCaptured;

  /// Constructs a MapCameraLocation widget.
  ///
  /// The [camera] parameter is required and represents the camera to be used for capturing images.
  /// The [onImageCaptured] parameter is an optional callback function that will be triggered when an image and location data are captured.
  const MapCameraLocation(
      {super.key, required this.camera, this.onImageCaptured});

  @override
  State<MapCameraLocation> createState() => _MapCameraLocationState();
}

class _MapCameraLocationState extends State<MapCameraLocation> {
  late CameraController _controller;

  /// Represents a controller for the camera, used to control camera-related operations.

  late Future<void> _initializeControllerFuture;

  /// Represents a future that resolves when the camera controller has finished initializing.

  late AlignOnUpdate _followOnLocationUpdate;

  /// Enum value indicating when to follow location updates.

  late StreamController<double?> _followCurrentLocationStreamController;

  /// Stream controller used to track the current location.

  File? cameraImagePath;

  /// File path of the captured camera image.

  File? ssImage;

  /// File path of the captured screen shot image.

  String? dateTime;

  /// A formatted string representing the current date and time.

  final globalKey = GlobalKey();

  /// Key used to uniquely identify and control a widget.

  Placemark? placeMark;

  /// Represents geocoded location information.

  LocationData? locationData;

  /// SubLocation of the current location as a string.

  /// Callback function to retrieve the image and location data.
  ImageAndLocationData getImageAndLocationData() {
    return ImageAndLocationData(
      imagePath: cameraImagePath?.path,
      locationData: locationData,
    );
  }

  Timer? _positionTimer;
  @override
  void initState() {
    super.initState();
    _positionTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (mounted) {
        await updatePosition(context);
      }
    });

    // Initialize the camera controller
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
    _followOnLocationUpdate = AlignOnUpdate.always;
    _followCurrentLocationStreamController = StreamController<double?>();

    // Get the current date and time in a formatted string
    dateTime = DateFormat.yMd().add_jm().format(DateTime.now());
  }

  @override
  void dispose() {
    _controller.dispose();
    _followCurrentLocationStreamController.close();
    _positionTimer?.cancel();
    super.dispose();
  }


  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        if (mounted) {
          super.setState(fn);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Center(
              child: RepaintBoundary(
                key: globalKey,
                child: Stack(
                  children: [
                    CameraPreview(
                      _controller,
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 10,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 160,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Card(
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0)),
                                    child: SizedBox(
                                      // height: 130,
                                      width: 120,
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: locationData == null
                                            ? const Center(
                                                child:
                                                    CircularProgressIndicator())
                                            : FlutterMap(
                                                options: MapOptions(
                                                  initialCenter:
                                                      const lat.LatLng(0, 0),
                                                  initialZoom: 13.0,
                                                  onPositionChanged:
                                                      (MapPosition position,
                                                          bool hasGesture) {
                                                    if (hasGesture) {
                                                      setState(
                                                        () =>
                                                            _followOnLocationUpdate =
                                                                AlignOnUpdate
                                                                    .never,
                                                      );
                                                    }
                                                  },
                                                ),
                                                children: [
                                                  TileLayer(
                                                    urlTemplate:
                                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                                    userAgentPackageName:
                                                        'com.example.app',
                                                    minZoom: 12,
                                                  ),
                                                  CurrentLocationLayer(
                                                    alignPositionStream:
                                                        _followCurrentLocationStreamController
                                                            .stream,
                                                    alignPositionOnUpdate:
                                                        _followOnLocationUpdate,
                                                  ),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.black.withOpacity(0.5)),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          locationData?.locationName ??
                                              "Loading...",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          locationData?.subLocation ??
                                              "Loading ..",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          "Lat ${locationData?.latitude ?? "Loading.."}",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          "Long ${locationData?.longitude ?? "Loading.."}",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          dateTime ?? "Loading...",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            takeScreenshot();
          } catch (e) {
            if (kDebugMode) {
              print(e);
            }
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }

  /// Takes a screenshot of the current screen and saves it as an image file.
  /// Returns the file path of the captured image and triggers the [onImageCaptured]
  /// callback if provided.
  /// Throws an exception if there is an error capturing the screenshot.
  Future<void> takeScreenshot() async {
    var rng = Random();

    // Get the render boundary of the widget
    final RenderRepaintBoundary boundary =
        globalKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;

    // Capture the screen as an image
    ui.Image image = await boundary.toImage();
    final directory = (await getApplicationDocumentsDirectory()).path;

    // Convert the image to bytes in PNG format
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    // Generate a random file name for the screenshot
    File imgFile = File('$directory/screenshot${rng.nextInt(200)}.png');

    // Write the bytes to the file
    await imgFile.writeAsBytes(pngBytes);

    // Check if the file exists
    bool isExists = imgFile.existsSync();

    if (isExists) {
      // Set the file path of the captured image
      setState(() {
        cameraImagePath = imgFile;
      });

      // Trigger the image captured callback
      if (widget.onImageCaptured != null) {
        ImageAndLocationData data = ImageAndLocationData(
          imagePath: imgFile.path,
          locationData: locationData,
        );
        widget.onImageCaptured!(data);
      }
    } else {
      debugPrint('File does not exist');
    }
  }

  /// Updates the current position by retrieving the latitude, longitude, location name,
  /// and subLocation based on the user's device location. Updates the corresponding
  /// state variables with the retrieved data.
  /// Throws an exception if there is an error retrieving the location information.
  Future<void> updatePosition(BuildContext context) async {
    try {
      // Determine the current position
      final position = await _determinePosition();

      // Retrieve the placeMarks for the current position
      final placeMarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      LocationData locationData;
      if (placeMarks.isNotEmpty) {
        final placeMark = placeMarks.first;

        locationData = LocationData(
            latitude: position.latitude.toString(),
            longitude: position.longitude.toString(),
            locationName:
                "${placeMark.locality ?? ""}, ${placeMark.administrativeArea ?? ""}, ${placeMark.country ?? ""}",
            subLocation:
                "${placeMark.street ?? ""}, ${placeMark.thoroughfare ?? ""} ${placeMark.administrativeArea ?? ""}");
      } else {
        locationData = LocationData(
            longitude: null,
            latitude: null,
            locationName: 'No Location Data',
            subLocation: "");
      }
      if (locationData != this.locationData) {
        // Update the state variables with the retrieved location data
        setState(() {
          this.locationData = locationData;
        });
      }

      if (kDebugMode) {
        print(
            "Latitude: ${locationData.latitude}, Longitude: ${locationData.longitude}, Location: ${locationData.locationName}");
      }
    } catch (e) {
      // Handle any errors that occurred during location retrieval
      setState(() {
        locationData = LocationData(
            longitude: null,
            latitude: null,
            locationName: 'Error Retrieving Location',
            subLocation: "");
      });
    }
  }

  /// Determines the current position using the GeoLocator package.
  /// Returns the current position as a [Position] object.
  /// Throws an exception if there is an error determining the position or if the necessary permissions are not granted.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // If location services are disabled, throw an exception
      throw Exception('Location services are disabled.');
    }
    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // If location permission is denied, request it
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // If location permission is still denied, throw an exception
        throw Exception('Location permissions are denied');
      }
    }

    // Check if location permission is permanently denied
    if (permission == LocationPermission.deniedForever) {
      // Throw an exception if location permission is permanently denied
      throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // Get the current position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
  }
}
