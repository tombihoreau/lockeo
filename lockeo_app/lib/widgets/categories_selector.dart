import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoriesSelector extends StatelessWidget {
  final List<Category> categories;
  final List<String> selectedCategories;
  final Function(List<String>) onChanged;

  const CategoriesSelector({
    super.key,
    required this.categories,
    required this.selectedCategories,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: categories.map((cat) {
        final isSelected = selectedCategories.contains(
          cat.categoryId.toString(),
        );

        return GestureDetector(
          onTap: () {
            final List<String> updated = List.from(selectedCategories);

            if (isSelected) {
              updated.remove(cat.categoryId.toString());
            } else {
              updated.add(cat.categoryId.toString());
            }

            onChanged(updated);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF00434A)
                    : Colors.grey.shade300,
                width: 1.5,
              ),
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
                      color: Color(0xFF00434A),
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
                        ? const Color(0xFF00434A)
                        : Colors.black87,
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
