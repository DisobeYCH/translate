import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  Future<String> getCountryCode() async {
    String countryCode = '';

    PermissionStatus status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      Position? position;
      List<Placemark> placemarks = [];

      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      } catch (e) {
        print('Failed to get location: $e');
      }

      if (position != null) {
        try {
          placemarks = await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );
        } catch (e) {
          print('Failed to get placemarks: $e');
        }

        if (placemarks.isNotEmpty) {
          Placemark placemark = placemarks[0];
          countryCode = placemark.isoCountryCode ?? '';
        }
      }
    } else {
      print('Location permission denied');
    }

    return countryCode;
  }
}
