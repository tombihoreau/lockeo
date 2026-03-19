import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lockeo_app/theme/app_text_styles.dart';
import '../../theme/app_colors.dart';

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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const Spacer(),

                  Text(
                    "Bienvenue sur",
                    style: AppTextStyles.hero.copyWith(color: Colors.white),
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

                  Text(
                    "Votre nouvelle solution pour\n"
                    "louer et faire louer des\n"
                    "équipements sportifs en toute\n"
                    "simplicité, près de chez vous.",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.h2.copyWith(color: Colors.white),
                  ),
                  const Spacer(),

                  Padding(
                    padding: EdgeInsets.only(bottom: 32),
                    child: SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/welcome_pages");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primaryRed,
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
