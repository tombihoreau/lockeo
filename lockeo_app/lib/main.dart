import 'package:flutter/material.dart';
import 'package:lockeo_app/screens/products_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lockeo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, // 👈 fond global
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,       // texte/icônes noirs
          elevation: 0,                        // pas d’ombre
        ),
      ),
      home: ProductsScreen(),
    );
  }
}