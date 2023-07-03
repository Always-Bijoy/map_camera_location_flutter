# map_camera_location

A Flutter package that provides a widget for capturing images with the device camera and retrieving the user's location information.
<br>

<img src="https://github.com/Always-Bijoy/map_camera_location_flutter/blob/main/assets/mapcamera.png" alt="Interface preview" width="400">

## Features

- Capture images using the device camera with attached Map
- Retrieve the user's current location (latitude, longitude, location name, and sublocation)
- Option to provide a callback function to receive the captured image and location data

## Getting Started

To use this package, add `map_camera_location` as a dependency in your `pubspec.yaml` file.

```yaml
dependencies:
  map_camera_location: ^2.0.0
```
### Usage

Import the package in your Dart file:

```dart
import 'package:map_camera_location/map_camera_location.dart';
```

## Permissions
Before using the package, make sure to add the necessary location permission to your AndroidManifest.xml file.

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

## Usage
The `MapCameraLocation` widget is used to capture images and retrieve location information. It requires a `CameraDescription` object and an optional callback function for receiving the captured image and location data.

```dart
MapCameraLocation(
  camera: yourCameraDescription,
  onImageCaptured: yourCallbackFunction,
)
```

The `camera` parameter is required and represents the camera to be used for capturing images. You can obtain a `CameraDescription` object using the `camera` package or any other camera plugin.

The `onImageCaptured` parameter is an optional callback function that will be triggered when an image and location data are captured. The function should have the following signature:

```dart
void yourCallbackFunction(ImageAndLocationData data) {
  // Handle the captured image and location data
}
```

The `ImageAndLocationData` object contains the captured image file path and the location information (latitude, longitude, location name, and sublocation).

The `MapCameraLocation` widget can be placed within your widget tree to display the camera preview and provide buttons or other UI elements for capturing images and updating location information.

### Example
Here's an example of how to use the `MapCameraLocation` widget:

```dart
import 'package:flutter/material.dart';
import 'package:map_camera_location/map_camera_location.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Camera Location Demo'),
        ),
        body: Center(
          child: MapCameraLocation(
            camera: yourCameraDescription,
            onImageCaptured: yourCallbackFunction,
          ),
        ),
      ),
    );
  }

  void yourCallbackFunction(ImageAndLocationData data) {
    // Handle the captured image and location data
    // For example, save the image to a file or display the location information
  }
}
```
For more information and detailed examples, refer to the package documentation.

### Issues and Contributions
If you encounter any issues or have suggestions for improvements, please file an issue on the GitHub repository.

Pull requests are also welcome! If you would like to contribute to this package, feel free to open a pull request with your proposed changes.

### License
This package is released under the MIT License. See the LICENSE file for more details.

```vbnet

Please note that you should replace `yourCameraDescription` and `yourCallbackFunction` with the appropriate values for your specific use case. Also, make sure to update the license and repository links with the correct information for your package.

Feel free to customize the README file further based on your package's specific features and requirements.

```