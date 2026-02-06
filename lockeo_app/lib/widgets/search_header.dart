import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:lockeo_app/theme/app_text_styles.dart';

class SearchHeader extends StatelessWidget {
  final String? initialQuery;
  final VoidCallback? onBack;
  final ValueChanged<String>? onChanged;
  final bool showBackButton;
  final TextEditingController controller;

  const SearchHeader({
    super.key,
    this.initialQuery,
    this.onBack,
    this.onChanged,
    this.showBackButton = true,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(20, statusBarHeight + 12, 20, 24),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        image: DecorationImage(
          image: AssetImage('assets/images/fond_bleu_header.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔙 Flèche + texte
          Row(
            children: [
              if (showBackButton)
                GestureDetector(
                  onTap: onBack ?? () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
              if (showBackButton) const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Que recherchez-vous ?",
                  style: AppTextStyles.h2.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 🔍 Barre de recherche
          TextField(
            controller: controller,
            onChanged: onChanged,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              hintText: "Objets, mot-clé...",
              hintStyle: const TextStyle(
                color: AppColors.blue800,
                fontSize: 13,
              ),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.search, color: AppColors.blue900),
              suffixIcon: (controller.text.isNotEmpty)
                  ? IconButton(
                      icon: const Icon(Icons.close, color: AppColors.blue900),
                      onPressed: () {
                        controller.clear();
                        onChanged?.call('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
