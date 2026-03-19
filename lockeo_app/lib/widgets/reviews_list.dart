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

    return ListView.separated(
      padding: const EdgeInsets.only(top: 2),
      itemCount: reviews.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final r = reviews[index];
        final author = allUsers.firstWhere((u) => u.userId == r.authorId);

        return _ReviewCard(review: r, author: author);
      },
    );
  }
}

class _ReviewCard extends StatefulWidget {
  final Review review;
  final User author;

  const _ReviewCard({required this.review, required this.author});

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  bool _expanded = false;
  bool _isOverflowing = false;

  @override
  Widget build(BuildContext context) {
    final review = widget.review;
    final author = widget.author;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review.title,
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
                    "${review.rating}",
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.jaunedegueu,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, constraints) {
              final textSpan = TextSpan(
                text: review.comment,
                style: const TextStyle(fontSize: 14, color: Colors.black),
              );
              final painter = TextPainter(
                text: textSpan,
                maxLines: 3,
                textDirection: TextDirection.ltr,
              )..layout(maxWidth: constraints.maxWidth);

              final hasOverflow = painter.didExceedMaxLines;
              if (_isOverflowing != hasOverflow) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  setState(() => _isOverflowing = hasOverflow);
                });
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.comment,
                    maxLines: _expanded ? null : 3,
                    overflow:
                        _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                  if (_isOverflowing) ...[
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => setState(() => _expanded = !_expanded),
                      child: Text(
                        _expanded ? "Voir moins" : "Voir plus",
                        style: AppTextStyles.link.copyWith(
                          color: AppColors.primaryBlue,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
