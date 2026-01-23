import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lockeo_app/theme/app_text_styles.dart';
import '../../theme/app_colors.dart';

class RegisterWelcomePage3Screen extends StatelessWidget {
  const RegisterWelcomePage3Screen();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 50),

          Text(
            "Créer votre compte\nen 3 étapes",
            textAlign: TextAlign.center,
            style: AppTextStyles.hero.copyWith(color: Colors.white),
          ),

          const SizedBox(height: 40),

          SvgPicture.asset("assets/icons/img_register3.svg", height: 180),

          const SizedBox(height: 32),

          Text(
            "Tous nos avantages !",
            style: AppTextStyles.h1.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: Text(
              "Retrouver notre paiement sécurisé, une messagerie instantanée, les avis et nos assurances.",
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: Colors.white),
            ),
          ),

          const SizedBox(height: 8),

          Center(
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/login'),
              child: Text(
                "J’ai déjà un compte",
                style: AppTextStyles.link.copyWith(
                  color: Colors.white,
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
                Navigator.pushNamed(context, "/register_1");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryRed,
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
