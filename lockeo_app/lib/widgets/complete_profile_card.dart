import 'package:flutter/material.dart';
import 'package:lockeo_app/theme/app_text_styles.dart';

class CompleteProfileCard extends StatelessWidget {
  final VoidCallback onPressed;
  final String backgroundAsset; // ex: "assets/images/profile_card_bg.png"
  final double height;

  const CompleteProfileCard({
    super.key,
    required this.onPressed,
    required this.backgroundAsset,
    this.height = 170,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(backgroundAsset, fit: BoxFit.cover),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Personnalisez votre profil",
                    style: AppTextStyles.h2.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 14),
                  RichText(
                    text: TextSpan(
                      style: AppTextStyles.body.copyWith(color: Colors.white),
                      children: [
                        TextSpan(
                          text: "Finalise ton profil pour débloquer le\nbadge ",
                        ),
                        TextSpan(
                          text: "“Loueur certifié”",
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton.icon(
                      onPressed: onPressed,
                      icon: const SizedBox.shrink(),
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Finaliser mon profil",
                            style: AppTextStyles.link.copyWith(
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                            size: 28,
                          ),
                        ],
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        foregroundColor: Colors.white,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        minimumSize: const Size(0, 0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
