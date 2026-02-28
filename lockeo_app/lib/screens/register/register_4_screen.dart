import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lockeo_app/theme/app_text_styles.dart';
import '../../theme/app_colors.dart';

class Register4Screen extends StatelessWidget {
  const Register4Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fond
          Positioned.fill(
            child: Image.asset(
              "assets/images/fond_bleu_page.png",
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 32),

                // Logo
                SvgPicture.asset("assets/icons/logo.svg", height: 35),

                const SizedBox(height: 100),

                // Texte principal
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Text(
                        "Votre compte a été\nvalidé !",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.hero.copyWith(color: Colors.white),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Nous avons envoyé un mail, pour que\nvous puissiez activer votre compte.",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.number.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // Icône validé
                Center(
                  child: Image.asset(
                    "assets/images/icon_check.png",
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),

                const Spacer(),

                // Bouton
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/register_5',
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: Text(
                        "CONTINUER",
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.primaryRed,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
