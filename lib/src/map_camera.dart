import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:latlong2/latlong.dart' as lat;
import '../../map_camera_flutter.dart';

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
///     print('Sublocation: ${data.subLocation}');
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
      {Key? key, required this.camera, this.onImageCaptured})
      : super(key: key);

  @override
  State<MapCameraLocation> createState() => _MapCameraLocationState();
}

class _MapCameraLocationState extends State<MapCameraLocation> {
  late CameraController _controller;

  /// Represents a controller for the camera, used to control camera-related operations.

  late Future<void> _initializeControllerFuture;

  /// Represents a future that resolves when the camera controller has finished initializing.

  late FollowOnLocationUpdate _followOnLocationUpdate;

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

  String? latitudeServer;

  /// Latitude value of the current location as a string.

  String? longitudeServer;

  /// Longitude value of the current location as a string.

  String? locationName;

  /// Name of the current location as a string.

  String? subLocation;

  /// Sublocation of the current location as a string.

  /// Callback function to retrieve the image and location data.
  ImageAndLocationData getImageAndLocationData() {
    return ImageAndLocationData(
      imagePath: cameraImagePath?.path,
      latitude: latitudeServer,
      longitude: longitudeServer,
      locationName: locationName,
      subLocation: subLocation,
    );
  }

  @override
  void initState() {
    super.initState();
    updatePosition(context);
    // Initialize the camera controller
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
    _followOnLocationUpdate = FollowOnLocationUpdate.always;
    _followCurrentLocationStreamController = StreamController<double?>();

    // Get the current date and time in a formatted string
    dateTime = DateFormat.yMd().add_jm().format(DateTime.now());
  }

  @override
  void dispose() {
    _controller.dispose();
    _followCurrentLocationStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return RepaintBoundary(
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Card(
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0)),
                                  child: SizedBox(
                                    // height: 130,
                                    width: 120,
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: latitudeServer == null
                                          ? const Center(
                                              child:
                                                  CircularProgressIndicator())
                                          : FlutterMap(
                                              options: MapOptions(
                                                center: const lat.LatLng(0, 0),
                                                zoom: 13.0,
                                                onPositionChanged:
                                                    (MapPosition position,
                                                        bool hasGesture) {
                                                  if (hasGesture) {
                                                    setState(
                                                      () => _followOnLocationUpdate =
                                                          FollowOnLocationUpdate
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
                                                  followCurrentLocationStream:
                                                      _followCurrentLocationStreamController
                                                          .stream,
                                                  followOnLocationUpdate:
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
                                        locationName ?? "Loading...",
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
                                        subLocation ?? "Loading ..",
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
                                        "Lat ${latitudeServer ?? "Loading.."}",
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
                                        "Long ${longitudeServer ?? "Loading.."}",
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
          latitude: latitudeServer,
          longitude: longitudeServer,
          locationName: locationName,
          subLocation: subLocation,
        );
        widget.onImageCaptured!(data);
      }
    } else {
      debugPrint('File does not exist');
    }
  }

  /// Updates the current position by retrieving the latitude, longitude, location name,
  /// and sublocation based on the user's device location. Updates the corresponding
  /// state variables with the retrieved data.
  /// Throws an exception if there is an error retrieving the location information.
  Future<void> updatePosition(BuildContext context) async {
    try {
      // Determine the current position
      final position = await _determinePosition();

      // Retrieve the placemarks for the current position
      final placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;

        // Update the state variables with the retrieved location data
        setState(() {
          latitudeServer = position.latitude.toString();
          longitudeServer = position.longitude.toString();
          locationName =
              "${placemark.locality ?? ""}, ${placemark.administrativeArea ?? ""}, ${placemark.country ?? ""}";
          subLocation =
              "${placemark.street ?? ""}, ${placemark.thoroughfare ?? ""} ${placemark.administrativeArea ?? ""}";
        });

        if (kDebugMode) {
          print(
              "Latitude: $latitudeServer, Longitude: $longitudeServer, Location: $locationName");
        }
      } else {
        // Handle case when no placemark is available
        setState(() {
          latitudeServer = null;
          longitudeServer = null;
          locationName = 'No Location Data';
          subLocation = '';
        });
      }
    } catch (e) {
      // Handle any errors that occurred during location retrieval
      setState(() {
        latitudeServer = null;
        longitudeServer = null;
        locationName = 'Error Retrieving Location';
        subLocation = '';
      });
    }
  }

  /// Determines the current position using the Geolocator package.
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
