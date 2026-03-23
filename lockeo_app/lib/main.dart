import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lockeo_app/models/offer.dart';
import 'package:lockeo_app/screens/home_screen.dart';
import 'package:lockeo_app/screens/categories_screen.dart';
import 'package:lockeo_app/screens/notifications_screen.dart';
import 'package:lockeo_app/screens/product_detail_screen.dart';
import 'package:lockeo_app/screens/register/register_welcome_screen.dart';
import 'package:lockeo_app/screens/search_screen.dart';
import 'package:lockeo_app/widgets/main_scaffold.dart';
import 'package:lockeo_app/screens/create_offer/create_offer_screen.dart';
import 'package:lockeo_app/screens/public_profile_screen.dart';
import 'package:lockeo_app/screens/user_profile_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lockeo_app/screens/conversations_screen.dart';
import 'package:lockeo_app/screens/login_screen.dart';
import 'package:lockeo_app/screens/register/register_welcome_pages_screen.dart';
import 'package:lockeo_app/screens/register/register_1_screen.dart';
import 'package:lockeo_app/screens/register/register_2_screen.dart';
import 'package:lockeo_app/screens/register/register_3_screen.dart';
import 'package:lockeo_app/screens/register/register_4_screen.dart';
import 'package:lockeo_app/screens/register/register_5_screen.dart';
import 'package:lockeo_app/screens/conversation_screen.dart';
import 'package:lockeo_app/services/app_notifications_realtime_service.dart';
import 'package:lockeo_app/services/backend_config.dart';
import 'package:lockeo_app/services/chat_socket_service.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BackendConfig.initialize();
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
      navigatorKey: appNavigatorKey,
      locale: const Locale('fr', 'FR'),
      supportedLocales: const [Locale('fr', 'FR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      title: 'Lockeo',
      builder: (context, child) {
        return GlobalNotificationsOverlay(
          child: child ?? const SizedBox.shrink(),
        );
      },
      theme: ThemeData(
        fontFamily: 'Montserrat',
        scaffoldBackgroundColor: const Color(0xFFF0F2F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      initialRoute: '/login',

      // 🧱 Routes statiques
      routes: {
        '/': (context) =>
            const MainScaffold(currentIndex: 0, child: HomeScreen()),
        '/categories': (context) =>
            const MainScaffold(currentIndex: 0, child: CategoriesScreen()),
        '/create': (context) =>
            const MainScaffold(currentIndex: 0, showBottomBar: false, child: CreateOfferScreen()),
        '/userProfile': (context) =>
            const MainScaffold(currentIndex: 4, child: UserProfileScreen()),
        '/discover': (context) =>
            const MainScaffold(currentIndex: 1, child: SearchPage()),
        '/messaging': (context) =>
            const MainScaffold(currentIndex: 3, child: ConversationsScreen()),
        '/login': (context) => const MainScaffold(
          showBottomBar: false,
          child: LoginScreen(),
        ),
        '/welcome': (context) => const MainScaffold(
          showBottomBar: false,
          child: RegisterWelcomeScreen(),
        ),
        '/welcome_pages': (context) => const MainScaffold(
          showBottomBar: false,
          child: RegisterWelcomePagesScreen(),
        ),
        '/register_1': (context) => const MainScaffold(
          showBottomBar: false,
          child: Register1Screen(),
        ),
        '/register_2': (context) => const MainScaffold(
          showBottomBar: false,
          child: Register2Screen(),
        ),
        '/register_3': (context) => const MainScaffold(
          showBottomBar: false,
          child: Register3Screen(),
        ),
        '/register_4': (context) => const MainScaffold(
          showBottomBar: false,
          child: Register4Screen(),
        ),
        '/register_5': (context) => const MainScaffold(
          showBottomBar: false,
          child: Register5Screen(),
        ),
        '/notifications': (context) => const MainScaffold(
          showBottomBar: true,
          currentIndex: 0,
          child: NotificationsScreen(),
        ),
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
                showBottomBar: false,
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
                child: PublicProfileScreen(userId: userId),
              ),
            );

          case '/conversation':
            final conversationId = settings.arguments as int?;

            if (conversationId == null) {
              return MaterialPageRoute(
                builder: (context) => const Scaffold(
                  body: Center(child: Text('Conversation introuvable')),
                ),
              );
            }

            return MaterialPageRoute(
              builder: (context) => MainScaffold(
                showBottomBar: false,
                currentIndex: 1,
                child: ConversationScreen(conversationId: conversationId),
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

class GlobalNotificationsOverlay extends StatefulWidget {
  const GlobalNotificationsOverlay({super.key, required this.child});

  final Widget child;

  @override
  State<GlobalNotificationsOverlay> createState() =>
      _GlobalNotificationsOverlayState();
}

class _GlobalNotificationsOverlayState extends State<GlobalNotificationsOverlay> {
  StreamSubscription<ChatNotificationEvent>? _notificationSub;
  Timer? _overlayTimer;
  ChatNotificationEvent? _latestNotification;
  bool _isBannerVisible = false;
  bool _connectionAttemptScheduled = false;

  @override
  void initState() {
    super.initState();
    _notificationSub = AppNotificationsRealtimeService.instance.notificationsStream
        .listen(_showNotification);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleConnectionAttempt();
  }

  @override
  void dispose() {
    _notificationSub?.cancel();
    _overlayTimer?.cancel();
    super.dispose();
  }

  void _scheduleConnectionAttempt() {
    if (_connectionAttemptScheduled) return;
    _connectionAttemptScheduled = true;

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _connectionAttemptScheduled = false;
      await AppNotificationsRealtimeService.instance.ensureConnected();
    });
  }

  void _showNotification(ChatNotificationEvent event) {
    _latestNotification = event;
    _overlayTimer?.cancel();
    if (mounted) {
      setState(() {
        _isBannerVisible = true;
      });
    }
    _overlayTimer = Timer(
      const Duration(seconds: 3),
      _hideBanner,
    );
  }

  void _openConversationFromNotification() {
    final notification = _latestNotification;
    _hideBanner();
    if (notification == null || notification.conversationId <= 0) return;
    appNavigatorKey.currentState?.pushNamed(
      '/conversation',
      arguments: notification.conversationId,
    );
  }

  void _hideBanner() {
    if (!mounted) return;
    setState(() {
      _isBannerVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    _scheduleConnectionAttempt();
    final notification = _latestNotification;
    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        widget.child,
        if (_isBannerVisible && notification != null)
          Positioned(
            top: topPadding + 12,
            left: 16,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: SafeArea(
                bottom: false,
                child: GestureDetector(
                  onTap: _openConversationFromNotification,
                  child: _GlobalNotificationBanner(
                    title: notification.title,
                    body: notification.body,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _GlobalNotificationBanner extends StatelessWidget {
  const _GlobalNotificationBanner({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F1FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none,
              color: Color(0xFF2F6BFF),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    color: Color(0xFF374151),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
