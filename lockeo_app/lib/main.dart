import 'package:flutter/material.dart';
import 'package:lockeo_app/models/offer.dart';
import 'package:lockeo_app/screens/home_screen.dart';
import 'package:lockeo_app/screens/products_screen.dart';
import 'package:lockeo_app/screens/categories_screen.dart';
import 'package:lockeo_app/screens/product_detail_screen.dart';
import 'package:lockeo_app/widgets/main_scaffold.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lockeo',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF0F2F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      initialRoute: '/',

      // 🧱 Routes statiques
      routes: {
        '/': (context) => const MainScaffold(
              currentIndex: 0,
              child: HomeScreen(),
            ),
        '/categories': (context) => const MainScaffold(
              currentIndex: 2,
              child: CategoriesScreen(),
            ),
      },

      // ⚙️ Routes dynamiques (avec arguments)
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/products':
            final query = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (context) => MainScaffold(
                currentIndex: 1,
                child: ProductsScreen(searchQuery: query),
              ),
            );

          case '/productDetails':
            final offer = settings.arguments as Offer?;
            if (offer == null) {
              return MaterialPageRoute(
                builder: (context) => const Scaffold(
                  body: Center(child: Text('Offre introuvable')),
                ),
              );
            }
            return MaterialPageRoute(
              builder: (context) => MainScaffold(
                currentIndex: 1,
                child: ProductDetailScreen(offer: offer),
              ),
            );

          default:
            return MaterialPageRoute(
              builder: (context) => const Scaffold(
                body: Center(child: Text('Page non trouvée')),
              ),
            );
        }
      },
    );
  }
}
