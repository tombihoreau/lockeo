import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class PublicProfileHeader extends StatelessWidget {
  final String firstName;
  final double rating;
  final int reviewsCount;

  final int transactionsCount;
  final bool isCertified;
  final bool isReactive;

  final VoidCallback? onBack;
  final VoidCallback? onMenu;

  const PublicProfileHeader({
    super.key,
    required this.firstName,
    required this.rating,
    required this.reviewsCount,
    this.transactionsCount = 0,
    this.isCertified = false,
    this.isReactive = false,
    this.onBack,
    this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 26),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        image: DecorationImage(
          image: AssetImage('assets/images/fond_bleu_header.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Top row: back + "Retour" + menu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: onBack,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),
                    Text(
                      "Retour",
                      style: AppTextStyles.h3.copyWith(color: Colors.white),
                    ),
                  ],
                ),
                const Icon(Icons.more_vert, color: Colors.white),
              ],
            ),

            const SizedBox(height: 24),

            // Avatar + name + rating
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage('assets/images/user.jpg'),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      firstName,
                      style: AppTextStyles.hero.copyWith(color: Colors.white),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          rating.toStringAsFixed(1),
                          style: AppTextStyles.hero.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            "$reviewsCount avis",
                            style: AppTextStyles.label.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Badges row
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _InfoBadge(
                  icon: Icons.compare_arrows_rounded,
                  label: "$transactionsCount\ntransactions",
                ),
                const SizedBox(width: 20),

                _InfoBadge(
                  icon: Icons.check_rounded,
                  label: "Profil\ncertifié",
                  isEnabled: isCertified,
                ),
                const SizedBox(width: 20),

                _InfoBadge(
                  icon: Icons.access_time_rounded,
                  label: "Réactif",
                  isEnabled: isReactive,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isEnabled;

  const _InfoBadge({
    required this.icon,
    required this.label,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Column(
        children: [
          Container(
            width: 37,
            height: 37,
            decoration: BoxDecoration(
              color: AppColors.secondaryBlue,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 21),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.label.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
