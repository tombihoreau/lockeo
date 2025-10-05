import 'package:flutter/material.dart';

class PromoCard extends StatelessWidget {
  final String title;
  final List<TextSpan> content; 
  final String linkText;
  final String imagePath;
  final VoidCallback onTap;
  final Color color;

  const PromoCard({
    super.key,
    required this.title,
    required this.content,
    required this.linkText,
    required this.imagePath,
    required this.onTap,
    this.color = const Color(0xFFFFA726), // 🔸 orange par défaut
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              // Image à gauche
              Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 16),

              // Texte à droite
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                        children: content, 
                      ),
                    ),
                    const SizedBox(height: 25),
                    
                    Align(
                      alignment: Alignment.bottomRight, 
                      child: GestureDetector(
                        onTap: onTap,
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              linkText,
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Icon(
                              Icons.arrow_right_alt,
                              color: color,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

  }
}
