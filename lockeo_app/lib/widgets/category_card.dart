import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CategoryCard extends StatelessWidget {
  final String name;
  final VoidCallback? onTap;

  const CategoryCard({super.key, required this.name, this.onTap});
  IconData _iconForLabel(String label) {
    final normalized = label.toLowerCase();
    if (normalized.contains('vélo') || normalized.contains('velo')) {
      return LucideIcons.mountainSnow;
    }
    if (normalized.contains('nautique')) return LucideIcons.waves;
    if (normalized.contains('randonnée')) return LucideIcons.trees;
    if (normalized.contains('sport de balle')) return LucideIcons.dribbble;
    return LucideIcons.box;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.blue50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _iconForLabel(name),
                size: 18,
                color: AppColors.blue900,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                name,
                style: AppTextStyles.caption.copyWith(color: Colors.black),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: AppColors.blue900, size: 18),
          ],
        ),
      ),
    );
  }
}
