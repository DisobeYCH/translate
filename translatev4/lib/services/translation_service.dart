import 'package:http/http.dart' as http;
import 'dart:convert';

class TranslationService {
  /// Traduit le texte donné en utilisant l'API DeepL.
  ///
  /// [text] : Le texte à traduire.
  /// [isoCode] : Le code de langue ISO de la langue cible.
  ///   Par exemple, "fr" pour le français, "es" pour l'espagnol, etc.
  ///
  /// Retourne une [Future] contenant la traduction du texte donné.
  /// Si la traduction est réussie, la traduction est renvoyée en tant que [String].
  /// Sinon, une erreur avec le code de statut HTTP est renvoyée en tant que [String].
  Future<String> translateText(String text, String? isoCode) async {
    final url = Uri.parse('https://api-free.deepl.com/v2/translate');
    final headers = {
      'Authorization': 'DeepL-Auth-Key 675c8b5e-0efb-c06a-4caf-387862d75b6a:fx',
      'Content-Type': 'application/x-www-form-urlencoded',
      'Origine': 'api-free.deepl.com',
    };

    // Les données de la requête
    final body = {
      'text': text,
      'target_lang': isoCode,
    };

    // Envoi de la requête POST à l'API DeepL
    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    // Vérification du code de statut HTTP de la réponse
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final translations = jsonResponse['translations'] as List<dynamic>;

      // Vérification si des traductions ont été renvoyées
      if (translations.isNotEmpty) {
        final translatedText = translations[0]['text'];
        final utf8Text = utf8
            .decode(translatedText.codeUnits); // Conversion du texte en UTF-8
        return utf8Text;
      }
    }

    // Gestion de l'erreur de requête
    return 'Erreur lors de l\'envoi de la requête : ${response.statusCode}';
  }
}
