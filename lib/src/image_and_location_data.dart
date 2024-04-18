class ImageAndLocationData {
  final String? imagePath;
  final LocationData? locationData;
  String? get latitude => locationData?.longitude;
  String? get longitude => locationData?.longitude;
  String? get locationName => locationData?.locationName;
  String? get subLocation => locationData?.subLocation;

  ImageAndLocationData({
    required this.imagePath,
    required this.locationData,
  });
}

class LocationData {
  /// Latitude value of the current location as a string.

  final String? latitude;

  /// Longitude value of the current location as a string.

  final String? longitude;

  /// Name of the current location as a string.

  final String? locationName;

  /// SubLocation of the current location as a string.

  final String? subLocation;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.subLocation,
  });

  @override
  bool operator ==(Object other) {
    return other is LocationData &&
        latitude == other.latitude &&
        longitude == other.longitude &&
        locationName == other.locationName &&
        subLocation == other.subLocation;
  }

  @override
  int get hashCode =>
      Object.hash(latitude, longitude, locationName, subLocation);
}
