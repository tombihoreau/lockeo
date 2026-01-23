import 'package:flutter/material.dart';

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
            // Background image
            Image.asset(
              backgroundAsset,
              fit: BoxFit.cover,
            ),

            // Optional: slight dark overlay (si besoin de lisibilité)
            // Container(color: Colors.black.withOpacity(0.05)),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Personnalise ton profil",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 14),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.25,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(text: "Finalise ton profil pour débloquer le\nbadge "),
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
                      // petit hack pour mettre l'icône à droite via "label + icon"
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            "Finaliser mon profil",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white,
                              decorationThickness: 2,
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
