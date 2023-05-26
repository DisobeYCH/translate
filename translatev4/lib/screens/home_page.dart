import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:translatev4/services/translation_service.dart';
import 'package:translatev4/services/location_service.dart';
import 'package:translatev4/services/image_picker_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? image;
  String textResult = '';
  String translatedText = '';
  TextRecognizer textDetector = GoogleMlKit.vision.textRecognizer();
  TranslationService translationService = TranslationService();
  LocationService locationService = LocationService();
  String countryCode = '';

  @override
  void initState() {
    super.initState();
    getLocation();
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

    await translateText();

    setState(() {});
  }

  Future<void> translateText() async {
    final translatedText = await translationService.translateText(textResult);
    setState(() {
      this.translatedText = translatedText;
    });
  }

  Future<void> getLocation() async {
    String countryCode = await locationService.getCountryCode();
    setState(() {
      this.countryCode = countryCode;
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
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(
                width: 300, // Remplacez la valeur par la largeur souhaitée
                child: ImagePickerButton(
                  onPressed: () async {
                    final result =
                        await ImagePickerService.pickImageFromGallery();
                    setState(() {
                      image = result;
                    });
                    await detectText();
                  },
                  label: 'Choisir une image de la galerie',
                ),
              ),
              SizedBox(
                width: 300, // Remplacez la valeur par la largeur souhaitée
                child: ImagePickerButton(
                  onPressed: () async {
                    final result =
                        await ImagePickerService.pickImageFromCamera();
                    setState(() {
                      image = result;
                    });
                    await detectText();
                  },
                  label: 'Prendre une photo',
                ),
              ),
              image != null
                  ? Image.file(image!)
                  : Text("Aucune image sélectionnée"),
              Text(translatedText != '' ? translatedText : ''),
              Text("Code ISO du pays : $countryCode"),
            ],
          ),
        ),
      ),
    );
  }
}

class ImagePickerButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const ImagePickerButton({
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      color: Colors.blue,
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: onPressed,
    );
  }
}
