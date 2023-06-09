import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<String> getCountryCode() async {
    String countryCode = '';

    try {
      Position position = await getPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        countryCode = placemark.isoCountryCode ?? '';
      }
    } catch (e) {
      print('Failed to get location: $e');
    }

    return countryCode;
  }

  Future<Position> getPosition() async {
    try {
      if (await Geolocator.isLocationServiceEnabled()) {
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      } else {
        throw Exception('Location service is not enabled');
      }
    } catch (e) {
      throw Exception('Failed to get position: $e');
    }
  }
}
