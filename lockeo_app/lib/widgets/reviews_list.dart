import 'package:flutter/material.dart';
import 'package:lockeo_app/models/review.dart';
import 'package:lockeo_app/models/user.dart';
import '../theme/app_colors.dart';
import 'package:lockeo_app/theme/app_text_styles.dart';

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
      padding: const EdgeInsets.only(top: 2),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final r = reviews[index];
        final author = allUsers.firstWhere((u) => u.userId == r.authorId);

        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
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
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Titre
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  Text(
                    r.title,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppColors.jaunedegueu,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${r.rating}",
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.jaunedegueu,
                        ),
                      ),
                    ],
                  ),
                ],
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
