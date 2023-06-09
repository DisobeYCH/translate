import 'package:http/http.dart' as http;
import 'dart:convert';


class TranslationService {
  Future<String> translateText(String text,String? isoCode) async {

    final url = Uri.parse('https://api-free.deepl.com/v2/translate');
    final headers = {
      
      'Authorization': 'DeepL-Auth-Key 675c8b5e-0efb-c06a-4caf-387862d75b6a:fx',
      'Content-Type': 'application/x-www-form-urlencoded',
      'Origine':'api-free.deepl.com',
    };

    // This will accept request from 
    final body = {
      'text': text,
      'target_lang': isoCode,
    };

    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final translations = jsonResponse['translations'] as List<dynamic>;
      if (translations.isNotEmpty) {
        final translatedText = translations[0]['text'];
        final utf8Text = utf8.decode(translatedText.codeUnits); // Convertir le texte en UTF-8
        return utf8Text;
      }
    }

    return 'Erreur lors de l\'envoi de la requête : ${response.statusCode}';
  }
}
