import 'package:flutter/material.dart';
import 'package:lockeo_app/models/user.dart';
import 'package:lockeo_app/models/offer.dart';
import 'package:lockeo_app/models/review.dart';
import 'package:lockeo_app/models/reservation.dart';
import 'package:lockeo_app/models/product.dart';
import 'package:lockeo_app/models/image.dart';
import 'package:lockeo_app/models/conversation.dart';

import 'package:lockeo_app/services/local_data_service.dart';
import 'package:lockeo_app/widgets/product_grid.dart';
import 'package:lockeo_app/widgets/reviews_list.dart';
import 'package:lockeo_app/widgets/profile_header.dart';
import 'package:lockeo_app/widgets/transactions_list.dart';

import '../theme/app_colors.dart';
import 'package:lockeo_app/theme/app_text_styles.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final dataService = LocalDataService();

  User? currentUser;

  List<Offer> myOffers = [];
  List<Offer> favorites = [];
  List<Review> reviews = [];
  List<User> allUsers = [];

  List<Product> products = [];
  List<ImageModel> images = [];
  List<Reservation> userReservations = [];
  List<Conversation> conversations = [];

  double averageRating = 0;
  int reviewsCount = 0;
  int transactionsCount = 0;

  int currentTabIndex = 0;
  bool isLoading = true;

  final List<GlobalKey> _tabKeys = List.generate(4, (_) => GlobalKey());
  final GlobalKey _lineKey = GlobalKey();

  double _underlineLeft = 0;
  double _underlineWidth = 0;
  bool _underlineReady = false;

  void _updateUnderline() {
    final tabCtx = _tabKeys[currentTabIndex].currentContext;
    final lineCtx = _lineKey.currentContext;
    if (tabCtx == null || lineCtx == null) return;

    final tabBox = tabCtx.findRenderObject() as RenderBox;
    final lineBox = lineCtx.findRenderObject() as RenderBox;

    final tabGlobal = tabBox.localToGlobal(Offset.zero);
    final lineGlobal = lineBox.localToGlobal(Offset.zero);

    if (!mounted) return;
    setState(() {
      _underlineLeft = tabGlobal.dx - lineGlobal.dx;
      _underlineWidth = tabBox.size.width;
      _underlineReady = true;
    });
  }

  @override
  void initState() {
    super.initState();
    currentTabIndex = 0;

    WidgetsBinding.instance.addPostFrameCallback((_) => _updateUnderline());
    loadData();
  }

  Future<void> loadData() async {
    await Future.delayed(const Duration(milliseconds: 200));

    final u = await dataService.getCurrentUser();
    final users = await dataService.loadUsers();

    final favs = (u != null)
        ? await dataService.getFavoriteOffers(u.userId)
        : <Offer>[];
    final offers = (u != null)
        ? await dataService.getOffersByUser(u.userId)
        : <Offer>[];
    final revs = (u != null)
        ? await dataService.getReviewsForUser(u.userId)
        : <Review>[];

    final reservations = await dataService.loadReservations();
    final prods = await dataService.loadProducts();
    final imgs = await dataService.loadImages();
    final convs = await dataService.loadConversations();

    List<Reservation> filteredReservations = [];
    if (u != null) {
      filteredReservations = reservations
          .where((r) => r.ownerId == u.userId || r.renterId == u.userId)
          .toList();
    }

    double sum = 0;
    for (final r in revs) {
      sum += r.rating;
    }

    if (!mounted) return;
    setState(() {
      currentUser = u;
      allUsers = users;

      favorites = favs;
      myOffers = offers;
      reviews = revs;

      reviewsCount = revs.length;
      averageRating = revs.isEmpty ? 0 : sum / revs.length;

      userReservations = filteredReservations;
      transactionsCount = filteredReservations.length;

      products = prods;
      images = imgs;
      conversations = convs;

      isLoading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _updateUnderline());
  }

  int? _findConversationId(Reservation r) {
    final me = currentUser!.userId;
    final otherUserId = (r.ownerId == me) ? r.renterId : r.ownerId;

    final byReservation = conversations.where(
      (c) => c.reservationId == r.reservationId,
    );
    if (byReservation.isNotEmpty) {
      return byReservation.first.conversationId;
    }

    final byUsersAndProduct = conversations.where((c) {
      final sameProduct = c.productId == r.productId;
      final hasUsers =
          c.userIds.contains(me) && c.userIds.contains(otherUserId);
      return sameProduct && hasUsers;
    });

    if (byUsersAndProduct.isNotEmpty) {
      return byUsersAndProduct.first.conversationId;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildTabs(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildTabContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return PublicProfileHeader(
      firstName: currentUser!.firstName,
      rating: averageRating,
      reviewsCount: reviewsCount,
      transactionsCount: transactionsCount,
      isCertified: true,
      isReactive: true,
      onBack: () =>
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
    );
  }

  Widget _buildTabs() {
    final tabs = ["Transactions", "Favoris", "Annonces", "Avis"];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(tabs.length, (index) {
              final isActive = currentTabIndex == index;

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() => currentTabIndex = index);
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => _updateUnderline(),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    tabs[index],
                    key: _tabKeys[index],
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                      color: isActive
                          ? AppColors.textPrimary
                          : AppColors.textGrey800,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          SizedBox(
            key: _lineKey,
            height: 3,
            width: double.infinity,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(height: 1, color: AppColors.cape300),
                ),
                if (_underlineReady)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    left: _underlineLeft,
                    bottom: 0,
                    child: Container(
                      height: 2,
                      width: _underlineWidth,
                      color: Colors.black,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (currentTabIndex) {
      case 0:
        return TransactionsList(
          reservations: userReservations,
          products: products,
          images: images,
          currentUserId: currentUser!.userId,
          onTapContact: (reservation) {
            final conversationId = _findConversationId(reservation);
            if (conversationId == null) return;

            Navigator.pushNamed(
              context,
              '/conversation',
              arguments: conversationId,
            );
          },
          onTapReview: (r) {
            // TODO
          },
        );

      case 1:
        return ProductGrid(offers: favorites);

      case 2:
        return ProductGrid(offers: myOffers);

      case 3:
        return ReviewsList(reviews: reviews, allUsers: allUsers);

      default:
        return const SizedBox.shrink();
    }
  }
}
