import 'package:flutter/material.dart';
import '../models/category.dart';
import 'package:lockeo_app/theme/app_colors.dart';
import 'package:lockeo_app/theme/app_text_styles.dart';

class CategoriesSelector extends StatefulWidget {
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
  State<CategoriesSelector> createState() => _CategoriesSelectorState();
}

class _CategoriesSelectorState extends State<CategoriesSelector> {
  int? _expandedParentId;

  // Instance "helper" pour réutiliser tes méthodes (onlyParents / childrenOf)
  // (comme elles ne sont pas static)
  final Category _catHelper = Category(categoryId: -1, label: "_helper");

  List<Category> get _parents => _catHelper.onlyParents(widget.categories);

  List<Category> _childrenOf(int parentId) =>
      _catHelper.childrenOf(widget.categories, parentId);

  void _toggleSelect(int categoryId) {
    if (!widget.selectable) return;

    final updated = List<int>.from(widget.selectedCategories);

    if (updated.contains(categoryId)) {
      updated.remove(categoryId);
    } else {
      updated.add(categoryId);
    }

    widget.onChanged(updated);
  }

  Widget _chip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    bool showCheck = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected && showCheck)
              Container(
                margin: const EdgeInsets.only(right: 6),
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 12, color: Colors.white),
              ),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isSelected ? AppColors.primaryBlue : AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parents = _parents;
    final children = (_expandedParentId == null)
        ? <Category>[]
        : _childrenOf(_expandedParentId!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: parents.map((parent) {
            final isOpen = _expandedParentId == parent.categoryId;

            return _chip(
              label: parent.label,
              isSelected: isOpen, // 👈 VISUEL BLEU + CHECK
              onTap: () {
                setState(() {
                  _expandedParentId = isOpen ? null : parent.categoryId;
                });
              },
            );
          }).toList(),
        ),

        if (_expandedParentId != null) ...[
          const SizedBox(height: 14),
          Text(
            "Sous-catégories",
            style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: children.map((child) {
              final isSelected = widget.selectedCategories.contains(
                child.categoryId,
              );

              return _chip(
                label: child.label,
                isSelected: isSelected,
                onTap: () => _toggleSelect(child.categoryId),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
