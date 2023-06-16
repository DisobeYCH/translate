import 'package:country_coder/country_coder.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Obtient le code pays à partir de la localisation de l'utilisateur.
  /// Retourne une [Future] de [String] contenant le code pays.
  Future<String> getCountryCode() async {
    String countryCode = '';
    final countries = CountryCoder.instance;
    countries.load(); // initialise l'instance, ne fait rien la deuxième fois

    // Vérifier et demander l'autorisation d'accès à la localisation
    LocationPermission status = await Geolocator.requestPermission();

    // Vérifier si l'autorisation a été accordée
    if (status == LocationPermission.whileInUse ||
        status == LocationPermission.always) {
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

  /// Récupère la position actuelle de l'appareil.
  ///
  /// Retourne un [Future] contenant un [Position] qui représente la position
  /// actuelle de l'appareil.
  /// Si le service de localisation est activé, la fonction utilise
  /// [Geolocator.getCurrentPosition] pour obtenir la position avec une précision
  /// élevée ([LocationAccuracy.high]).
  /// Si le service de localisation n'est pas activé, une [Exception] est levée
  /// avec le message "Le service de localisation n'est pas activé".
  /// Si une erreur se produit lors de l'obtention de la position, une [Exception]
  /// est levée avec le message "Échec de l'obtention de la position : [erreur]".

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
