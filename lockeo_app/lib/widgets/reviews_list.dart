import 'package:flutter/material.dart';
import 'package:lockeo_app/models/review.dart';
import 'package:lockeo_app/models/user.dart';

class ReviewsList extends StatelessWidget {
  final List<Review> reviews;
  final List<User> allUsers;

  const ReviewsList({super.key, required this.reviews, required this.allUsers});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return const Center(child: Text("Aucun avis disponible"));
    }

    return ListView.builder(
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final r = reviews[index];
        final author = allUsers.firstWhere((u) => u.userId == r.authorId);

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
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage('assets/images/user.jpg'),
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
                      const Icon(Icons.star, color: Colors.amber, size: 18),
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

              Text(r.comment, style: const TextStyle(fontSize: 14)),
            ],
          ),
        );
      },
    );
  }
}
