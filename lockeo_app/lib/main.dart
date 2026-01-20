import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lockeo_app/models/offer.dart';
import 'package:lockeo_app/screens/home_screen.dart';
import 'package:lockeo_app/screens/categories_screen.dart';
import 'package:lockeo_app/screens/product_detail_screen.dart';
import 'package:lockeo_app/screens/register_welcome_screen.dart';
import 'package:lockeo_app/screens/search_screen.dart';
import 'package:lockeo_app/widgets/main_scaffold.dart';
import 'package:lockeo_app/screens/create_offer_screen.dart';
import 'package:lockeo_app/screens/public_profile_screen.dart';
import 'package:lockeo_app/screens/user_profile_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lockeo_app/screens/conversations_screen.dart';
import 'package:lockeo_app/screens/login_screen.dart';
import 'package:lockeo_app/screens/register_welcome_pages_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Aucun init de localisation ici (restauré à l'état précédent)
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('fr', 'FR'),
      supportedLocales: const [Locale('fr', 'FR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      title: 'Lockeo',
      theme: ThemeData(
        textTheme: GoogleFonts.montserratTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFF0F2F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      initialRoute: '/welcome',

      // 🧱 Routes statiques
      routes: {
        '/': (context) =>
            const MainScaffold(currentIndex: 0, child: HomeScreen()),
        '/categories': (context) =>
            const MainScaffold(currentIndex: 2, child: CategoriesScreen()),
        '/create': (context) =>
            const MainScaffold(currentIndex: 3, child: CreateOfferScreen()),
        '/userProfile': (context) =>
            const MainScaffold(currentIndex: 1, child: UserProfileScreen()),
        '/discover': (context) =>
            const MainScaffold(currentIndex: 1, child: SearchPage()),
        '/messaging': (context) =>
            const MainScaffold(currentIndex: 1, child: ConversationsScreen()),
        '/login': (context) =>
            const MainScaffold(showBottomBar: false, currentIndex: 1, child: LoginScreen()),
        '/welcome': (context) =>
            const MainScaffold(showBottomBar: false, currentIndex: 1, child: RegisterWelcomeScreen()),
        '/welcome_pages': (context) =>
            const MainScaffold(showBottomBar: false, currentIndex: 1, child: RegisterWelcomePagesScreen()),
      },

      // ⚙️ Routes dynamiques (avec arguments)
      onGenerateRoute: (settings) {
        switch (settings.name) {
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

          case '/search':
            final query = settings.arguments as String?;
            return MaterialPageRoute(
              builder: (context) => MainScaffold(
                currentIndex: 1,
                child: SearchPage(initialQuery: query),
              ),
            );

          case '/user':
            final userId = settings.arguments as int;
            if (userId <= 0) {
              return MaterialPageRoute(
                builder: (context) => const Scaffold(
                  body: Center(child: Text('Utilisateur introuvable')),
                ),
              );
            }
            return MaterialPageRoute(
              builder: (context) => MainScaffold(
                showBottomBar: false,
                currentIndex: 1,
                child: PublicProfileScreen(userId: userId),
              ),
            );

          default:
            return MaterialPageRoute(
              builder: (context) =>
                  const Scaffold(body: Center(child: Text('Page non trouvée'))),
            );
        }
      },
    );
  }
}
