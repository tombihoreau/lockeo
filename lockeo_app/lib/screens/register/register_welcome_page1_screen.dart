import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lockeo_app/theme/app_text_styles.dart';

class RegisterWelcomePage1Screen extends StatelessWidget {
  const RegisterWelcomePage1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 80),

          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
              children: [
                TextSpan(
                  text: "Économisez, partagez et\nconsommez autrement\navec ",
                  style: AppTextStyles.h1.copyWith(color: Colors.white),
                ),

                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: SvgPicture.asset('assets/icons/logo.svg', height: 20),
                ),
              ],
            ),
          ),

          const SizedBox(height: 72),

          // BULLET 1
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: const Icon(
                      Icons.sync,
                      color: AppColors.blue800,
                      size: 20,
                    ),
                  ),
                ),

                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Louez plutôt qu’acheter",
                        style: AppTextStyles.h2.copyWith(color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Accédez à ce dont vous avez besoin sans dépenser plus.",
                        style: AppTextStyles.body.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // BULLET 2
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: const Icon(
                      Icons.eco,
                      color: AppColors.blue800,
                      size: 20,
                    ),
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Agissez pour la planète",
                        style: AppTextStyles.h2.copyWith(color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Moins d’objets inutilisés, plus de réutilisation.",
                        style: AppTextStyles.body.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // BULLET 3
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: const Icon(
                      Icons.people,
                      color: AppColors.blue800,
                      size: 20,
                    ),
                  ),
                ),

                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Rencontrez vos voisins",
                        style: AppTextStyles.h2.copyWith(color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Une communauté de confiance, locale et active.",
                        style: AppTextStyles.body.copyWith(color: Colors.white),
                      ),
                    ],
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
