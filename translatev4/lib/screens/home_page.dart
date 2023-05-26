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
  String dropdownValue = 'Option 1';
  List<String> dropdownOptions = ['Selectionner langue', 'Option 2', 'Option 3'];

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
      backgroundColor: Color(
          0xFFffffff), // Utilisez la valeur hexadécimale avec le préfixe "0xFF"
// Remplacez par la couleur de fond souhaitée

      appBar: AppBar(
        title: Center(
          child: Text(
            widget.title,
            style: TextStyle(
              color: const Color.fromARGB(255, 255, 255, 255),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        elevation: 0,
        backgroundColor: Color(0xFFe63946),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 40),
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        image != null ? Color(0xFF1d3557) : Color(0xFF1d3557),
                  ),
                ),
                child: Center(
                  child: image != null
                      ? Image.file(image!)
                      : Text("Aucune image sélectionnée"),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: 300,
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
                width: 300,
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
              SizedBox(height: 10),
              Container(
                width: 300,
                height: 35,
                decoration: BoxDecoration(
                  color: Color(0xFF1d3557),
                ),
                child: Center(
                  child: DropdownButton<String>(
                    value: dropdownValue,
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue = newValue!;
                      });
                    },
                    items: dropdownOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        
                        child: Center(
                          child: Text(
                            value,
                            style: TextStyle(
                          
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: 300,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: image != null
                        ? Color(0xFFe63946)
                        : Color.fromARGB(0, 255, 252, 252),
                  ),
                ),
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      Text(translatedText != '' ? translatedText : ''),
                    ],
                  ),
                ),
              ),
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
      color: Color(0xFF1d3557),
      child: Text(
        label,
        style: TextStyle(
          color: Color.fromARGB(255, 255, 255, 255),
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: onPressed,
    );
  }
}
