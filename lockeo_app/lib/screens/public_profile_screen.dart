import 'package:flutter/material.dart';
import 'package:lockeo_app/utils/app_navigator.dart';
import 'package:lockeo_app/models/user.dart';
import 'package:lockeo_app/services/local_data_service.dart';
import 'package:lockeo_app/models/offer.dart';
import 'package:lockeo_app/models/review.dart';
import 'package:lockeo_app/widgets/reviews_list.dart';
import 'package:lockeo_app/widgets/product_grid.dart';
import 'package:lockeo_app/widgets/button.dart';
import 'package:lockeo_app/theme/app_text_styles.dart';
import 'package:lockeo_app/theme/app_colors.dart';
import 'package:lockeo_app/widgets/profile_header.dart';
import 'package:lockeo_app/models/reservation.dart';

class PublicProfileScreen extends StatefulWidget {
  final int userId;

  const PublicProfileScreen({super.key, required this.userId});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final dataService = LocalDataService();
  late final PageController _pageController;

  User? user;
  bool isLoading = true;

  List<Offer> userOffers = [];
  List<Review> userReviews = [];
  List<User> allUsers = [];

  double averageRating = 0;
  int reviewsCount = 0;

  int currentTabIndex = 0;

  final List<GlobalKey> _tabKeys = List.generate(2, (_) => GlobalKey());
  final GlobalKey _lineKey = GlobalKey();

  double _underlineLeft = 0;
  double _underlineWidth = 0;
  bool _underlineReady = false;
  List<Reservation> userReservations = [];
  int transactionsCount = 0;

  void _updateUnderline() {
    final tabCtx = _tabKeys[currentTabIndex].currentContext;
    final lineCtx = _lineKey.currentContext;

    if (tabCtx == null || lineCtx == null) return;

    final tabBox = tabCtx.findRenderObject() as RenderBox;
    final lineBox = lineCtx.findRenderObject() as RenderBox;

    final tabGlobal = tabBox.localToGlobal(Offset.zero);
    final lineGlobal = lineBox.localToGlobal(Offset.zero);

    setState(() {
      _underlineLeft = tabGlobal.dx - lineGlobal.dx;
      _underlineWidth = tabBox.size.width;
      _underlineReady = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    currentTabIndex = 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateUnderline();
    });

    loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    final u = await dataService.getUserById(widget.userId);
    final offers = await dataService.loadOffers();
    final reviews = await dataService.loadReviews();
    final users = await dataService.loadUsers();

    final reservations = await dataService.loadReservations();
    final filteredReviews = reviews
        .where((r) => r.ownerId == widget.userId)
        .toList();

    final filteredReservations = reservations
        .where((r) => r.ownerId == widget.userId || r.renterId == widget.userId)
        .toList();

    double sum = 0;
    for (final r in filteredReviews) {
      sum += r.rating;
    }

    setState(() {
      user = u;

      userOffers = offers.where((o) => o.userId == widget.userId).toList();
      userReviews = filteredReviews;
      reviewsCount = filteredReviews.length;
      averageRating = filteredReviews.isEmpty
          ? 0
          : sum / filteredReviews.length;

      userReservations = filteredReservations;
      transactionsCount = filteredReservations.length;
      allUsers = users;
      isLoading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateUnderline();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (user == null) {
      return const Center(child: Text("Utilisateur introuvable"));
    }

    const double bottomSize = 110;

    return Container(
      color: const Color(0xFFF0F2F5),
      child: SafeArea(
        top: false,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // CONTENU (on réserve de la place en bas pour le footer)
                Column(
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 16),
                    _buildTabs(),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          16,
                          0,
                          16,
                          bottomSize,
                        ),
                        child: _buildTabContent(),
                      ),
                    ),
                  ],
                ),

                // FOOTER collé en bas
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildBottomCta(bottomSize),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return PublicProfileHeader(
      firstName: user!.firstName,
      rating: averageRating,
      reviewsCount: reviewsCount,
      transactionsCount: transactionsCount,
      isCertified: true,
      isReactive: true,
      onBack: () => AppNavigator.back(context),
    );
  }

  Widget _buildTabs() {
    final tabs = [
      "Annonces (${userOffers.length})",
      "Evaluations ($reviewsCount)",
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(tabs.length, (index) {
              final isActive = currentTabIndex == index;

              return Padding(
                padding: EdgeInsets.only(right: index == 0 ? 24 : 0),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      tabs[index],
                      key: _tabKeys[index],
                      style: AppTextStyles.h3.copyWith(
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: isActive ? AppColors.textPrimary : AppColors.textGrey800,
                      ),
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
                  )
                else
                  const Positioned(
                    left: 0,
                    bottom: 0,
                    child: SizedBox.shrink(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() => currentTabIndex = index);
        WidgetsBinding.instance.addPostFrameCallback((_) => _updateUnderline());
      },
      children: [
        ProductGrid(offers: userOffers),
        ReviewsList(reviews: userReviews, allUsers: allUsers),
      ],
    );
  }

  Widget _buildBottomCta(double height) {
    return Container(
      height: height,
      padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Center(
        child: SizedBox(
          width: 300,
          child: CustomButton(text: "Envoyer un message", onPressed: () {}),
        ),
      ),
    );
  }
}
