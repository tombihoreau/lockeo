import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CategoryCard extends StatelessWidget {
  final String name;
  final String iconUrl;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.name,
    required this.iconUrl,
    this.onTap,
  });

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
          mainAxisSize: MainAxisSize.min, // 👈 permet à la carte de s’adapter à son contenu
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF225A5D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SvgPicture.asset(
                iconUrl,
                width: 18,
                height: 18,
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
                softWrap: true,              // ✅ permet les retours à la ligne
                overflow: TextOverflow.visible, // ✅ ne coupe plus le texte
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
