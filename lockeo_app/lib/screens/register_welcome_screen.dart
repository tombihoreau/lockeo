import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegisterWelcomeScreen extends StatelessWidget {
  const RegisterWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fond (asset)
          Positioned.fill(
            child: Image.asset(
              "assets/images/fond_bleu_page.png", 
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const Spacer(),

                  const Text(
                    "Bienvenue sur",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Logo (asset)
                   Center(
                    child: SvgPicture.asset(
                      'assets/icons/logo.svg',
                      height: 60,
                    ),
                  ),

                  const SizedBox(height: 44),

                  const Text(
                    "Votre nouvelle solution pour\n"
                    "louer et faire louer des\n"
                    "équipements sportifs en toute\n"
                    "simplicité, près de chez vous.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),

                  const Spacer(),

                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 32,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/welcome_pages");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFD1380D),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: const Text(
                          "DÉCOUVRIR LOCKEO",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
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
