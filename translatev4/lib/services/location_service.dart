import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:country_coder/country_coder.dart';

class LocationService {
  Future<String> getCountryCode() async {
    String countryCode = '';
    final countries = CountryCoder.instance;
    countries.load(); // initialize the instance, does nothing the second time

// Find a country's 2-letter ISO code by longitude and latitude

    try {
      Position position = await getPosition();
      countryCode = countries.iso1A2Code(
          lon: position.longitude, lat: position.latitude) as String;
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
