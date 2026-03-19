import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CategoryCard extends StatelessWidget {
  final String name;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.name,
    this.onTap,
  });

  IconData _iconForLabel(String label) {
    final normalized = label.toLowerCase();
    if (normalized.contains('vélo') || normalized.contains('velo')) return LucideIcons.bike;
    if (normalized.contains('hiver')) return LucideIcons.snowflake;
    if (normalized.contains('nata') || normalized.contains('eau')) return LucideIcons.waves;
    if (normalized.contains('randonn') || normalized.contains('mont')) return LucideIcons.mountain;
    if (normalized.contains('camp')) return LucideIcons.tent;
    if (normalized.contains('escala') || normalized.contains('grimpe')) return LucideIcons.hand;
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
                color: const Color(0xFF225A5D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _iconForLabel(name),
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF225A5D),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
