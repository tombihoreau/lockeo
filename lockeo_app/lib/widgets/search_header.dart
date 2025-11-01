import 'package:flutter/material.dart';

class SearchHeader extends StatelessWidget {
  final String? initialQuery;
  final VoidCallback? onBack;
  final ValueChanged<String>? onChanged;
  final bool showBackButton;

  const SearchHeader({
    super.key,
    this.initialQuery,
    this.onBack,
    this.onChanged,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final controller = TextEditingController(text: initialQuery ?? '');

    return Container(
      padding: EdgeInsets.fromLTRB(20, statusBarHeight + 12, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF00434A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
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
              const Expanded(
                child: Text(
                  "Que recherchez-vous ?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
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
            decoration: InputDecoration(
              hintText: "Objets, mot-clé...",
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: (controller.text.isNotEmpty)
                  ? IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
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
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
