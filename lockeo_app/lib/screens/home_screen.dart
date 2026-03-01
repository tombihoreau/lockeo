import 'package:flutter/material.dart';
import '../widgets/product_grid.dart';
import '../widgets/category_grid.dart';
import '../widgets/header.dart';
import '../widgets/favorites_section.dart';
import '../theme/app_colors.dart';
import '../widgets/complete_profile_card.dart';
import '../widgets/main_scaffold.dart';
import 'package:lockeo_app/theme/app_text_styles.dart';
import 'package:lockeo_app/services/location_service.dart';
import '../services/auth_session.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _loc = LocationService();
  String _locationLabel = "Rennes, France";

  @override
  void initState() {
    super.initState();
    _loadStored();
  }

  Future<void> _loadStored() async {
    final stored = await _loc.getStoredLabel();
    if (!mounted) return;
    setState(() {
      _locationLabel = stored ?? _locationLabel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🟢 Header en plein écran
            Header(
              userName: AuthSession.instance.displayName,
              location: _locationLabel,
              isHome: true,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                            const SizedBox(width: 4),
                            const Icon(
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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Nos suggestions",
                        style: AppTextStyles.h2.copyWith(color: Colors.black),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MainScaffold(
                                currentIndex: 1,
                                child: SearchPage(initialSortBy: "Popularité"),
                              ),
                            ),
                          );
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
                            const SizedBox(width: 4),
                            const Icon(
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
                    sortBy: "Popularité",
                    shrinkWrap: true,
                  ),
                  const SizedBox(height: 40),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          "Les plus populaires près de chez vous",
                          softWrap: true,
                          style: AppTextStyles.h2.copyWith(color: Colors.black),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MainScaffold(
                                currentIndex: 1,
                                child: SearchPage(initialSortBy: "Distance"),
                              ),
                            ),
                          );
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
                            const SizedBox(width: 4),
                            const Icon(
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
                    sortBy: "Distance",
                    shrinkWrap: true,
                  ),
                  const SizedBox(height: 40),

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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MainScaffold(
                                currentIndex: 1,
                                child: SearchPage(favoritesOnly: true),
                              ),
                            ),
                          );
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
                            const SizedBox(width: 4),
                            const Icon(
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
                  // 🔵 Section favoris (masquée si l'utilisateur n'a pas de favoris)
                  const FavoritesSection(maxItems: 4),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
