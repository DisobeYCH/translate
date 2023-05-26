import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:translatev4/services/translation_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? image;
  String textResult = '';
  String translatedText = ''; // Nouvelle variable pour le texte traduit
  TextRecognizer textDetector = GoogleMlKit.vision.textRecognizer();
  TranslationService translationService = TranslationService(); // Instance du service de traduction

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
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

      await detectText();
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future<void> detectText() async {
    if (image == null) return;

    final inputImage = InputImage.fromFile(image!);
    final result = await textDetector.processImage(inputImage);

    textResult = '';

    for (TextBlock block in result.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement element in line.elements) {
          textResult += element.text + ' ';
        }
      }
    }

    // Appeler la méthode de traduction
    await translateText();

    setState(() {});
  }

  Future<void> translateText() async {
    final translatedText = await translationService.translateText(textResult);
    setState(() {
      this.translatedText = translatedText;
    });
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
              Text(translatedText), // Afficher le texte traduit
            ],
          ),
        ),
      ),
    );
  }
}
