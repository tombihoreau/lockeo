import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CategoryCard extends StatelessWidget {
  final String name;
  final String iconName;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.name,
    required this.iconName,
    this.onTap,
  });

  IconData _getIconByName(String iconName) { //voir si y'a besoin du switch
    switch (iconName) {
      case 'bike':
        return LucideIcons.bike;
      case 'snowflake':
        return LucideIcons.snowflake;
      case 'waves':
        return LucideIcons.waves;
      case 'mountain':
        return LucideIcons.mountain;
      case 'tent':
        return LucideIcons.tent;
      case 'hand':
        return LucideIcons.hand;
      default:
        return LucideIcons.box; // icône par défaut
    }
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
                _getIconByName(iconName),
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
