import 'package:flutter/material.dart';
import '../models/category.dart';
import '../theme/app_colors.dart';

class CategoriesSelector extends StatelessWidget {
  final List<Category> categories;
  final List<int> selectedCategories;
  final Function(List<int>) onChanged;
  final bool selectable;

  const CategoriesSelector({
    super.key,
    required this.categories,
    required this.selectedCategories,
    required this.onChanged,
    this.selectable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: categories.map((cat) {
        final isSelected = selectedCategories.contains(cat.categoryId);

        return GestureDetector(
          onTap: () {
            if (!selectable) return;
            final List<int> updated = List.from(selectedCategories);

            if (isSelected) {
              updated.remove(cat.categoryId);
            } else {
              updated.add(cat.categoryId);
            }

            onChanged(updated);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected)
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                Text(
                  cat.label,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
