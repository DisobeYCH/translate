/**
 * Ce fichier contient le code source principal de l'application.
 * Il démarre l'application en appelant la fonction `main()`.
 */

import 'package:flutter/material.dart';
import 'package:translatev4/screens/home_page.dart';

void main() {
  /**
 * `MyApp` est la classe principale de l'application.
 * Elle étend la classe `StatelessWidget` de Flutter et représente l'ensemble de l'interface utilisateur.
 */

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  /**
   * La méthode `build` est responsable de la construction de l'interface utilisateur.
   * Elle reçoit un `BuildContext` en paramètre qui contient des informations sur le contexte actuel de l'application.
   * La méthode retourne un objet `MaterialApp` qui représente l'application avec un titre et une page d'accueil.
   */
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Translate',
      home: const MyHomePage(title: 'DeepTranslate'),
    );
  }
}
