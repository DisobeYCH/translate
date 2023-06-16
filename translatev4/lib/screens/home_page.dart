import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:translatev4/services/translation_service.dart';
import 'package:translatev4/services/location_service.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'dart:async';
import 'package:translatev4/services/image_picker_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

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
      await Future.delayed(Duration(seconds: 1)); // Attendre 2 secondes

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
        bottom: PreferredSize(
            child: Container(
              color: Color(0xFF00a6fb),
              height: 1.0,
            ),
            preferredSize: Size.fromHeight(4.0)),

        elevation: 0,
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        toolbarHeight: 60, // Réduit la hauteur de la barre d'outils
        title: Row(
          mainAxisAlignment:
              MainAxisAlignment.center, // Centrer les éléments horizontalement
          children: [
            Container(
              child: DropdownButtonHideUnderline(
                // Cache la ligne de soulignement du bouton déroulant
                child: DropdownButton2(
                  isExpanded: true,
                  items: items
                      .map((item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00a6fb),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                  value: selectedValue,
                  onChanged: (value) {
                    setState(() {
                      selectedValue = value as String;
                      translateText();
                    });
                  },
                  buttonStyleData: ButtonStyleData(
                    height: 50,
                    width: 160,
                  ),
                  iconStyleData: const IconStyleData(
                    icon: Icon(
                      Icons.translate,
                    ),
                    iconSize: 25,
                    iconEnabledColor: Color(0xFF00a6fb),
                  ),
                  dropdownStyleData: DropdownStyleData(
                    width: 170,
                    padding: null,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
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
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: textController,
                maxLines: null, // Permet un nombre de lignes dynamique
                decoration: InputDecoration(
                  border:
                      InputBorder.none, // Supprime la bordure du champ de texte
                  hintText:
                      "Ecrivez ou collez un texte, ou traduisez du\ncontenu depuis l'une des sources ci-dessous", // Texte indicatif
                  suffixIcon: textController.text.isEmpty
                      ? null // Si le texte est égal à hintText, le suffixIcon est nul (invisible)
                      : IconButton(
                          icon: Icon(
                              Icons.clear), // Icône pour supprimer le texte
                          onPressed: () {
                            textController.clear(); // Effacer le texte
                          },
                        ),
                ),
              ),
            ),
          ),
          Divider(
            // Ligne de séparation grise
            color: Color(0xFF00a6fb),
            thickness: 1,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                readOnly: true, // Rend le champ de texte en lecture seule
                controller: TextEditingController(text: translatedText),
                decoration: InputDecoration(
                  border: InputBorder.none, // Supprime la bordure
                  suffixIcon: Visibility(
                    visible: translatedText
                        .isNotEmpty, // Affiche l'icône uniquement si translatedText n'est pas vide
                    child: IconButton(
                      icon: Icon(Icons.copy), // Icône de copie
                      onPressed: () {
                                Clipboard.setData(ClipboardData(text: translatedText));

                        // Logique pour copier le texte
                        // Affichage d'un message ou d'une boîte de dialogue indiquant que le texte a été copié
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Texte copié !'),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                maxLines: null, // Permet un nombre de lignes dynamique
              ),
            ),
          ),
          Container(
            height: 50, // Hauteur du pied de page
            decoration: BoxDecoration(),
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
    // Vérifier si l'application s'exécute sur Flutter Web
    if (!kIsWeb) {
      return MaterialButton(
        minWidth: width,
        height: 40,
        child: Icon(
          icon,
          color: Color(0xFF00a6fb),
          size: 40,
        ),
        onPressed: onPressed,
      );
    } else {
      // Retourner un widget vide pour Flutter Web
      return SizedBox();
    }
  }
}
