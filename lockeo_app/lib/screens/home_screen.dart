import 'package:flutter/material.dart';
import '../widgets/product_grid.dart';
import '../widgets/category_grid.dart';
import '../widgets/header.dart';
import '../theme/app_colors.dart';
import '../widgets/complete_profile_card.dart';
import 'package:lockeo_app/theme/app_text_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🟢 Header en plein écran
            const Header(
              userName: "Tom",
              location: "Rennes, France",
              isHome: true,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🟢 Section catégories
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Nos catégories",
                        style: AppTextStyles.h2.copyWith(color: Colors.black),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/categories');
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min, // important
                          children: [
                            Text(
                              "Tout voir",
                              style: AppTextStyles.link.copyWith(
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right,
                              color: AppColors.primaryBlue,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const CategoryGrid(maxItems: 4),
                  const SizedBox(height: 40),

                  CompleteProfileCard(
                    backgroundAsset: "assets/images/fond_bleu_bandeau.png",
                    onPressed: () {
                      Navigator.pushNamed(context, "/userProfile");
                    },
                  ),
                  const SizedBox(height: 20),

                  // 🟣 Section suggestions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Nos suggestions",
                        style: AppTextStyles.h2.copyWith(color: Colors.black),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/products');
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min, // important
                          children: [
                            Text(
                              "Tout voir",
                              style: AppTextStyles.link.copyWith(
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right,
                              color: AppColors.primaryBlue,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const ProductGrid(
                    maxItems: 4,
                    randomize: true,
                    shrinkWrap: true,
                  ),
                  const SizedBox(height: 40),

                  // 🟠 Section populaires
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "Les plus populaires près de chez vous",
                          style: AppTextStyles.h2.copyWith(color: Colors.black),

                          softWrap: true,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/products');
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min, 
                          children: [
                            Text(
                              "Tout voir",
                              style: AppTextStyles.link.copyWith(
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right,
                              color: AppColors.primaryBlue,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const ProductGrid(
                    maxItems: 4,
                    randomize: true,
                    shrinkWrap: true,
                  ),
                  const SizedBox(height: 40),

                  // 🔵 Section favoris
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "Vos favoris",
                          style: AppTextStyles.h2.copyWith(color: Colors.black),
                          softWrap: true,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/products');
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min, // important
                          children: [
                            Text(
                              "Tout voir",
                              style: AppTextStyles.link.copyWith(
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right,
                              color: AppColors.primaryBlue,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const ProductGrid(
                    maxItems: 4,
                    favoritesOnly: true,
                    shrinkWrap: true,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
