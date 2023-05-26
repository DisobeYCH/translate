import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? image;
  String translatedText = ''; // Variable pour stocker le texte traduit
  TextRecognizer textDetector = GoogleMlKit.vision.textRecognizer();

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (image == null) return;

      final imageTemp = File(image.path);

      setState(() => this.image = imageTemp);

      // Détecter le texte dans l'image
      await detectText();
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future pickImageC() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);

      if (image == null) return;

      final imageTemp = File(image.path);

      setState(() => this.image = imageTemp);

      // Détecter le texte dans l'image
      await detectText();
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future<void> detectText() async {
    if (image == null) return;

    final inputImage = InputImage.fromFile(image!);
    final result = await textDetector.processImage(inputImage);

    // Réinitialiser le texte traduit
    translatedText = '';

    for (TextBlock block in result.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement element in line.elements) {
          translatedText += element.text + ' '; // Ajouter l'élément de texte traduit au résultat avec un espace
        }
      }
    }

    // Envoyer la requête HTTP avec les paramètres spécifiés
    await sendTranslationRequest(translatedText);

    setState(() {}); // Mettre à jour l'interface utilisateur avec le texte traduit
  }

Future<void> sendTranslationRequest(String text) async {
  final url = Uri.parse('https://api-free.deepl.com/v2/translate');
  final headers = {
    'Authorization': 'DeepL-Auth-Key 675c8b5e-0efb-c06a-4caf-387862d75b6a:fx',
    'User-Agent': 'YourApp/1.2.3',
    'Content-Type': 'application/x-www-form-urlencoded',
  };
  final body = {
    'text': text,
    'target_lang': 'DE',
  };

  final response = await http.post(
    url,
    headers: headers,
    body: body,
  );

  if (response.statusCode == 200) {
    // Traitement de la réponse ici
    final jsonResponse = jsonDecode(response.body);
    final translations = jsonResponse['translations'] as List<dynamic>;
    if (translations.isNotEmpty) {
      final translatedText = translations[0]['text'];
      setState(() {
        this.translatedText = translatedText;
      });
    }
  } else {
    setState(() {
      translatedText = 'Erreur lors de l\'envoi de la requête : ${response.statusCode}';
    });
  }
}


  @override
  void dispose() {
    textDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Picker Example"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              MaterialButton(
                color: Colors.blue,
                child: const Text(
                  "Choisir une image de la galerie",
                  style: TextStyle(
                      color: Colors.white70, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  pickImage();
                },
              ),
              MaterialButton(
                color: Colors.blue,
                child: const Text(
                  "Prendre une photo",
                  style: TextStyle(
                      color: Colors.white70, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  pickImageC();
                },
              ),
              SizedBox(height: 20,),
              image != null ? Image.file(image!) : Text("Aucune image sélectionnée"),
              SizedBox(height: 20,),
              Text(translatedText),
            ],
          ),
        ),
      ),
    );
  }
}
