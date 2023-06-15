import 'package:country_coder/country_coder.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<String> getCountryCode() async {
    String countryCode = '';
    final countries = CountryCoder.instance;
    countries.load(); // initialise l'instance, ne fait rien la deuxième fois

    // Vérifier et demander l'autorisation d'accès à la localisation
    LocationPermission status = await Geolocator.requestPermission();

    // Vérifier si l'autorisation a été accordée
    if (status == LocationPermission.whileInUse || status == LocationPermission.always) {
      try {
        Position position = await getPosition();
        countryCode = countries.iso1A2Code(
            lon: position.longitude, lat: position.latitude) as String;
      } catch (e) {
        print('Échec de l\'obtention de la localisation : $e');
      }
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
        throw Exception('Le service de localisation n\'est pas activé');
      }
    } catch (e) {
      throw Exception('Échec de l\'obtention de la position : $e');
    }
  }
}
