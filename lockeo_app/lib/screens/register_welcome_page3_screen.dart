import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegisterWelcomePage3Screen extends StatelessWidget {
  const RegisterWelcomePage3Screen();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 50),

          const Text(
            "Créer votre compte\nen 3 étapes",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 40),

          SvgPicture.asset("assets/icons/img_register3.svg", height: 180),

          const SizedBox(height: 32),

          const Text(
            "Tous nos avantages !",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: Text(
              "Retrouver notre paiement sécurisé, une messagerie instantanée, les avis et nos assurances.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Center(
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/login'),
              child: const Text(
                "J’ai déjà un compte",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/register");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFD1380D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: const Text(
                "CRÉER MON COMPTE",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
