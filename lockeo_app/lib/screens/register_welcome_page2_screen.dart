import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lockeo_app/theme/app_text_styles.dart';

class RegisterWelcomePage2Screen extends StatelessWidget {
  const RegisterWelcomePage2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 80),

          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: AppTextStyles.h1.copyWith(color: Colors.white),
              children: [
                const TextSpan(text: "Le fonctionnement de "),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: SvgPicture.asset('assets/icons/logo.svg', height: 35),
                ),
              ],
            ),
          ),

          const SizedBox(height: 72),

          // STEP 1
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "1",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Recherchez un équipement sportif",
                      style: AppTextStyles.h2.copyWith(color: Colors.white),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Trouvez ce dont vous avez besoin près de chez vous grâce à notre moteur de recherche.",
                      style: AppTextStyles.body.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // STEP 2
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "2",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Réservez et payez en sécurité",
                      style: AppTextStyles.h2.copyWith(color: Colors.white),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Notifications en temps réel, paiement sécurisé et assurance pour chaque location.",
                      style: AppTextStyles.body.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // STEP 3
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "3",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Rencontrez le propriétaire",
                      style: AppTextStyles.h2.copyWith(color: Colors.white),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Récupérez l’objet, utilisez-le, puis laissez un avis et gagnez en confiance.",
                      style: AppTextStyles.body.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
