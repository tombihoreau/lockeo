import 'package:flutter/material.dart';
import 'package:lockeo_app/models/user.dart';
import 'package:lockeo_app/services/local_data_service.dart';
import 'package:lockeo_app/models/offer.dart';
import 'package:lockeo_app/models/review.dart';
import '../widgets/product_grid.dart';
import '../widgets/button.dart';

class PublicProfileScreen extends StatefulWidget {
  final int userId;

  const PublicProfileScreen({super.key, required this.userId});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final dataService = LocalDataService();
  User? user;
  bool isLoading = true;
  List<Offer> userOffers = [];
  List<Review> userReviews = [];
  double averageRating = 0;
  int reviewsCount = 0;
  int currentTabIndex = 0;
  List<User> allUsers = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final u = await dataService.getUserById(widget.userId);
    final offers = await dataService.loadOffers();
    final reviews = await dataService.loadReviews();
    final users = await dataService.loadUsers();

    final userReviews = reviews
        .where((r) => r.ownerId == widget.userId)
        .toList();

    double sum = 0;
    for (var r in userReviews) {
      sum += r.rating;
    }

    setState(() {
      user = u;
      userOffers = offers.where((o) => o.userId == widget.userId).toList();
      allUsers = users;
      this.userReviews = userReviews;
      averageRating = userReviews.isEmpty ? 0 : sum / userReviews.length;

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Utilisateur introuvable")),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(
              top: 50,
              left: 16,
              right: 16,
              bottom: 28,
            ),
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
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
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

                // Avatar + nom + note
                Row(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: const AssetImage(
                        'assets/images/user.jpg',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user!.firstName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "$reviewsCount avis",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 70,
                      height: 80,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.compare_arrows,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "118 transactions", // forcer une forme plus propre si tu veux
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      width: 70,
                      height: 80,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.verified,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Profil certifié",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      width: 70,
                      height: 80,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.access_time,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Réactif",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => currentTabIndex = 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Annonces (${userOffers.length})",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: currentTabIndex == 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: currentTabIndex == 0
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 2,
                        width: 80,
                        color: currentTabIndex == 0
                            ? Colors.black
                            : Colors.transparent,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 24),

                GestureDetector(
                  onTap: () => setState(() => currentTabIndex = 1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Evaluations (${userReviews.length})",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: currentTabIndex == 1
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: currentTabIndex == 1
                              ? Colors.black
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 2,
                        width: 90,
                        color: currentTabIndex == 1
                            ? Colors.black
                            : Colors.transparent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: currentTabIndex == 0
                  ? ProductGrid(offers: userOffers)
                  : ListView.builder(
                      itemCount: userReviews.length,
                      itemBuilder: (context, index) {
                        final r = userReviews[index];
                        final author = allUsers.firstWhere(
                          (u) => u.userId == r.authorId,
                        );

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // avatar + pseudo + note
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundImage: const AssetImage(
                                      'assets/images/user.jpg',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      author.firstName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "${r.rating}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Titre
                              Text(
                                r.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 6),

                              LayoutBuilder(
                                builder: (context, constraints) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        r.comment,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 6),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        alignment: Alignment.center,
        height: 100,
        child: SizedBox(
          width: 300,
          child: CustomButton(
            text: "Envoyer un message",
            onPressed: () {
              
            },
          ),
        ),
      ),
    );
  }
}
