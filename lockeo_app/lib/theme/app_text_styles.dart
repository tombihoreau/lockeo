import 'package:flutter/material.dart';

class AppTextStyles {
  // 🔥 TITRE HERO
  static const TextStyle hero = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800, // ExtraBold
    height: 1.2,
  );

  // 🟦 HEADING 1
  static const TextStyle h1 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800, // ExtraBold
    height: 1.25,
  );

  // 🟦 HEADING 2
  static const TextStyle h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700, // Bold
    height: 1.3,
  );

  // 🟦 HEADING 3
  static const TextStyle h3 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600, // SemiBold
    height: 1.3,
  );

  // 🔢 CHIFFRE (18px ExtraBold)
  static const TextStyle chiffre = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800, // ExtraBold
    height: 1.2,
  );

  // 🔘 BOUTON (18px Bold Italic)
  static const TextStyle button = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700, // Bold
    fontStyle: FontStyle.italic,
    height: 1.2,
    letterSpacing: 1.0,
  );

  // 🔢 NOMBRE (16px SemiBold)
  static const TextStyle number = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600, // SemiBold
    height: 1.2,
  );

  // 📄 BODY (16px Regular)
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400, // Regular
    height: 1.4,
  );

  // 🏷️ CAPTION (14px SemiBold)
  static const TextStyle caption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600, // SemiBold
    height: 1.3,
  );

  // 🔗 LIEN (14px Medium)
  static const TextStyle link = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500, // Medium
    height: 1.3,
    decoration: TextDecoration.underline,
  );

  // 🏷️ LABEL (12px Regular)
  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400, // Regular
    height: 1.2,
  );
}
