import 'package:flutter/material.dart';
import 'package:lockeo_app/screens/categories_screen.dart';
import '../widgets/product_grid.dart';
import 'products_screen.dart';
import '../widgets/button.dart';
import '../widgets/category_grid.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accueil"),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🟢 Section catégories
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Nos catégories",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategoriesScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Tout voir",
                      style: TextStyle(
                        color: Color(0xFF225A5D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              // 🟢 Le widget qui affiche les 4 catégories
              const SizedBox(height: 10),
              const CategoryGrid(maxItems: 4),
              const SizedBox(height: 20),

              // 🟣 Section suggestions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Nos suggestions",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductsScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Tout voir",
                      style: TextStyle(
                        color: Color(0xFF225A5D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              const ProductGrid(maxItems: 4, randomize: true, shrinkWrap: true),
              const SizedBox(height: 40),

              // 🟠 Section populaires
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Les plus populaires près de chez vous",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      softWrap: true,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductsScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Tout voir",
                      style: TextStyle(
                        color: Color(0xFF225A5D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              const ProductGrid(maxItems: 4, randomize: true, shrinkWrap: true),
              const SizedBox(height: 40),

              // 🔵 Section favoris
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Vos favoris",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      softWrap: true,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductsScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Tout voir",
                      style: TextStyle(
                        color: Color(0xFF225A5D),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              const ProductGrid(maxItems: 4, favoritesOnly: true, shrinkWrap: true),
            ],
          ),
        ),
      ),
    );
  }
}
