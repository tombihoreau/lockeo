import 'package:flutter/material.dart';
import 'package:lockeo_app/models/user.dart';
import 'package:lockeo_app/models/offer.dart';
import 'package:lockeo_app/models/review.dart';
import 'package:lockeo_app/services/local_data_service.dart';
import 'package:lockeo_app/widgets/product_grid.dart';
import 'package:lockeo_app/widgets/reviews_list.dart';

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

  int currentTabIndex = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await Future.delayed(const Duration(milliseconds: 200));
    currentUser = await dataService.getCurrentUser();
    allUsers = await dataService.loadUsers();

    if (currentUser != null) {
      myOffers = await dataService.getOffersByUser(currentUser!.userId);
      favorites = await dataService.getFavoriteOffers(currentUser!.userId);
      reviews = await dataService.getReviewsForUser(currentUser!.userId);
    }

    setState(() {
      isLoading = false;
    });
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D4154), Color(0xFF145A6A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ligne du bouton retour + menu
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Retour",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
              const Icon(Icons.more_vert, color: Colors.white),
            ],
          ),

          const SizedBox(height: 26),

          // Avatar
          const Center(
            child: CircleAvatar(
              radius: 45,
              backgroundImage: AssetImage('assets/images/user.jpg'),
            ),
          ),

          const SizedBox(height: 12),

          // Nom
          Center(
            child: Text(
              currentUser!.firstName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),

          // Email
          Center(
            child: Text(
              currentUser!.email,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    final tabs = ["Transactions", "Favoris", "Annonces", "Avis"];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(tabs.length, (index) {
          final isActive = currentTabIndex == index;

          return GestureDetector(
            onTap: () => setState(() => currentTabIndex = index),
            child: Column(
              children: [
                Text(
                  tabs[index],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive ? Colors.black : Colors.grey[600],
                  ),
                ),
                if (isActive)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    height: 2,
                    width: 40,
                    color: Colors.black,
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (currentTabIndex) {
      case 0:
        return const Center(child: Text("Aucune transaction pour le moment"));
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
