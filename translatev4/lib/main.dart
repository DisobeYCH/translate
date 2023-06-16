// main.dart
/// @pragma('utf-8')
import 'package:flutter/material.dart';
import 'package:translatev4/screens/home_page.dart';


void main() {
  
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      title: 'Translate',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        
      ),
      home: const MyHomePage(title: 'DeepTranslate'),
    );
  }
}
