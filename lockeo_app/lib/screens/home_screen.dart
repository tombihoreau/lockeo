import 'package:flutter/material.dart';
import '../widgets/product_grid.dart';
import 'products_screen.dart';
import '../widgets/promo_card.dart';
import '../widgets/button.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Accueil")),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      "Voir tout",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              const ProductGrid(maxItems: 4, randomize: true, shrinkWrap: true,),

              const SizedBox(height: 40),

              PromoCard(
                title: "Un objet qui ne sert qu’une fois ?",
                content: [
                  const TextSpan(
                    text: "Donnez-lui une deuxième vie… en location !",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(
                    text: "Facile à mettre en ligne, sécurisé, et rentable. ",
                  ),
                ],
                linkText: "Ajouter un objet en location",
                imagePath: 'assets/icons/icon_lamp.png',
                color: Color(0xFF06B3C4), // 🎨 couleur personnalisée
                onTap: () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductsScreen(),
                  ),
                );
                },
              ),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Les plus populaires près de chez vous",
                      style: TextStyle(
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
                      "Voir tout",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              const ProductGrid(maxItems: 4, randomize: true, shrinkWrap: true,),

              const SizedBox(height: 40),

              PromoCard(
                title: "Notre catégorie spécial vacances",
                content: [
                  const TextSpan(
                    text: "Tout ce qu’il vous faut pour des vacances au top, sans exploser le budget.\n",
                  ),
                  const TextSpan(
                    text: "Louez, profitez, rendez : aussi simple que ça !",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
                linkText: "Découvrir",
                imagePath: 'assets/icons/icon_beach.png',
                color: Colors.orange, // 🎨 couleur personnalisée
                onTap: () {
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductsScreen(),
                  ),
                );
                },
              ),
              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Vos favoris",
                      style: TextStyle(
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
                      "Voir tout",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              const ProductGrid(maxItems: 4, favoritesOnly: true, shrinkWrap: true,),

              const SizedBox(height: 40),

              // 🟢 Bloc "Gérez vos disponibilités"
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1FBF3), // fond vert très clair
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ligne icône + texte principal
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icône calendrier
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F4EA),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.calendar_month,
                            color: Color(0xFF0B6623),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Texte titre + description
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Gérez vos disponibilités en un clic !",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "Donnez-lui une seconde vie !\nAjoutez une nouvelle annonce en quelques clics.",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    CustomButton( 
                      text: "Gérer mon calendrier",
                      color: const Color(0xFF0B6623),
                      onPressed: () {
                        // 👉 action quand on clique sur le bouton
                        // exemple :
                        // Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarScreen()));
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

            ],
          ),
        ),
      ),
    );
  }
}
