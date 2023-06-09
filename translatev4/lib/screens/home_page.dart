import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:translatev4/services/translation_service.dart';
import 'package:translatev4/services/location_service.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'dart:async';
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
  final List<String> items = [
    'Localisation',
    'Français',
    'Anglais',
    'Allemand',
  ];
  String? selectedValue = 'Localisation';
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    getLocation();
    super.initState();
    textController.addListener(() async {
      await Future.delayed(Duration(seconds: 2)); // Attendre 2 secondes

      setState(() {
        textResult = textController.text;
      });

      translateText();
    });
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
  setState(() {});
  await translateText();

  setState(() {
textController.text = textResult;
  });
}


  Future<void> translateText() async {
    final translatedText = await translationService.translateText(
        textResult, obtenirCodeIso(selectedValue));
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

  String obtenirCodeIso(String? libele) {
    if (libele == "Localisation") {
      if (countryCode == "CH") {
        libele = "Français";
      }
    }
    switch (libele) {
      case "Français":
        return "FR";
      case "Anglais":
        return "EN";
      case "Allemand":
        return "DE";
      default:
        return "Error le language selectionné n'existe pas";
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
      backgroundColor: Color(
          0xFFffffff), // Utilisez la valeur hexadécimale avec le préfixe "0xFF"
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xFFe63946),
        toolbarHeight: 40, // Réduit la hauteur de la barre d'outils
        title: Row(
          mainAxisAlignment:
              MainAxisAlignment.center, // Centrer les éléments horizontalement
          children: [
            Container(
              child: DropdownButtonHideUnderline(
                child: DropdownButton2(
                  hint: Text(
                    'Localisation',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  items: items
                      .map((item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ))
                      .toList(),
                  value: selectedValue,
                  onChanged: (value) {
                    setState(() {
                      selectedValue = value as String;
                    });
                    translateText();
                  },
                  buttonStyleData: const ButtonStyleData(
                    height: 40,
                  ),
                  menuItemStyleData: const MenuItemStyleData(
                    height: 40,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              child: TextField(
                controller: textController,
                maxLines: null, // Permet un nombre de lignes dynamique
                decoration: InputDecoration(
                  border:
                      InputBorder.none, // Supprime la bordure du champ de texte
                  hintText: 'Saisissez du texte...', // Texte indicatif
                ),
              ),
            ),
          ),
          Divider(
            // Ligne de séparation grise
            color: Color(0xFFe63946),
            thickness: 1,
          ),
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  translatedText,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
          Container(
            height: 50, // Hauteur du pied de page
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Color(0xFFe63946), // Couleur de la bordure grise
                  width: 1.0, // Épaisseur de la bordure
                ),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 40), // Ajoute une marge horizontale de 20 pixels
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ImagePickerButton(
                    onPressed: () async {
                      final result =
                          await ImagePickerService.pickImageFromGallery();
                      setState(() {
                        image = result;
                      });
                      await detectText();
                    },
                    icon: CupertinoIcons.photo_fill_on_rectangle_fill,
                  ),
                  ImagePickerButton(
                    onPressed: () async {
                      final result =
                          await ImagePickerService.pickImageFromCamera();
                      setState(() {
                        image = result;
                      });
                      await detectText();
                    },
                    icon: CupertinoIcons.photo_camera,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ImagePickerButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final double width; // Ajoutez cette ligne

  const ImagePickerButton({
    required this.onPressed,
    required this.icon,
    this.width =
        40, // Définissez une valeur par défaut pour la largeur du bouton
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      minWidth: width, // Utilisez la contrainte de largeur fournie
      height: 40, // Définissez la hauteur du bouton selon vos besoins
      color: Color(0xFF1d3557),
      child: Icon(
        icon,
        color: Color.fromARGB(255, 255, 255, 255),
        size: 20,
      ),
      onPressed: onPressed,
    );
  }
}
