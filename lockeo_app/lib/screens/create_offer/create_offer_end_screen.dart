import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../widgets/button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lockeo_app/theme/app_colors.dart';
import 'package:lockeo_app/theme/app_text_styles.dart';

class CreateOfferEndScreen extends StatelessWidget {
  final String offerTitle;
  final String offerDescription;
  final String offerImagePath;
  final int offerCount;

  const CreateOfferEndScreen({
    super.key,
    required this.offerTitle,
    required this.offerDescription,
    required this.offerImagePath,
    required this.offerCount,
  });

  Widget _buildOfferImage() {
    if (offerImagePath.trim().isEmpty) {
      return Container(
        width: 90,
        height: 90,
        color: Colors.grey.shade200,
        child: const Icon(Icons.image_outlined),
      );
    }

    if (offerImagePath.startsWith('assets/')) {
      return Image.asset(
        offerImagePath,
        width: 90,
        height: 90,
        fit: BoxFit.cover,
      );
    }

    return Image.file(
      File(offerImagePath),
      width: 90,
      height: 90,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: 90,
        height: 90,
        color: Colors.grey.shade200,
        child: const Icon(Icons.broken_image_outlined),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/icon_check.svg',
                  width: 80,
                  height: 80,
                ),
                const SizedBox(height: 16),

                Text(
                  "Votre annonce a été ajoutée !",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  "Vous venez de poster votre $offerCountᵉ annonce" + (offerCount > 1 ? "s" : ""),
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 32),

                // Carte annonce
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: _buildOfferImage(),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: SizedBox(
                          height: 90,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                offerTitle,
                                style: AppTextStyles.h2,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const Spacer(),

                              GestureDetector(
                                onTap: () {
                                  // Naviguer vers l'annonce
                                },
                                child: Text(
                                  "Voir mon annonce",
                                  style: AppTextStyles.link.copyWith(
                                    color: AppColors.primaryBlue,
                                    decorationColor: AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/');
                  },
                  child: Text(
                    "Retour à la page d’accueil",
                    style: AppTextStyles.link.copyWith(
                      color: AppColors.primaryRed,
                      decorationColor: AppColors.primaryRed,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 54,
            child: CustomButton(
              text: "Ajouter une nouvelle annonce",
              onPressed: () {
                Navigator.pushNamed(context, '/create');
              },
            ),
          ),
        ),
      ),
    );
  }
}
