import 'package:flutter/material.dart';

import '../models/category.dart';
import 'package:lockeo_app/theme/app_colors.dart';
import 'package:lockeo_app/theme/app_text_styles.dart';

class OfferCategoriesSelector extends StatelessWidget {
  final List<Category> categories;
  final List<int> selectedCategories;
  final ValueChanged<List<int>> onChanged;
  final bool selectable;

  const OfferCategoriesSelector({
    super.key,
    required this.categories,
    required this.selectedCategories,
    required this.onChanged,
    this.selectable = true,
  });

  List<Category> get _parents =>
      categories.where((c) => (c.parentId ?? 0) == 0).toList()
        ..sort((a, b) => a.label.compareTo(b.label));

  int? get _selectedParentId {
    final byId = {
      for (final category in categories) category.categoryId: category,
    };

    for (final categoryId in selectedCategories) {
      final category = byId[categoryId];
      if (category?.isParent == true) {
        return category!.categoryId;
      }
    }

    for (final categoryId in selectedCategories) {
      final category = byId[categoryId];
      if (category?.isChild == true) {
        return category!.parentId;
      }
    }

    return null;
  }

  List<Category> _childrenOf(int parentId) =>
      categories.where((c) => (c.parentId ?? 0) == parentId).toList()
        ..sort((a, b) => a.label.compareTo(b.label));

  List<int> _currentChildren(int parentId) {
    final childrenIds = _childrenOf(parentId).map((c) => c.categoryId).toSet();
    return selectedCategories.where(childrenIds.contains).toList();
  }

  void _selectParent(int parentId) {
    if (!selectable) return;

    if (_selectedParentId == parentId) {
      onChanged(const []);
      return;
    }

    onChanged([parentId]);
  }

  void _toggleChild(int childId) {
    if (!selectable || _selectedParentId == null) return;

    final parentId = _selectedParentId!;
    final updatedChildren = List<int>.from(_currentChildren(parentId));

    if (updatedChildren.contains(childId)) {
      updatedChildren.remove(childId);
    } else {
      updatedChildren.add(childId);
    }

    updatedChildren.sort();
    onChanged([parentId, ...updatedChildren]);
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
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
          ),
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
    final selectedParentId = _selectedParentId;
    final children = selectedParentId == null
        ? <Category>[]
        : _childrenOf(selectedParentId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _parents.map((parent) {
            final isSelected = selectedParentId == parent.categoryId;
            return _chip(
              label: parent.label,
              isSelected: isSelected,
              onTap: () => _selectParent(parent.categoryId),
            );
          }).toList(),
        ),
        if (selectedParentId != null) ...[
          const SizedBox(height: 14),
          Text(
            "Sous-catégories",
            style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          if (children.isEmpty)
            Text(
              "Aucune sous-catégorie disponible pour cette catégorie.",
              style: AppTextStyles.caption.copyWith(color: AppColors.textGrey),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: children.map((child) {
                final isSelected = selectedCategories.contains(
                  child.categoryId,
                );
                return _chip(
                  label: child.label,
                  isSelected: isSelected,
                  onTap: () => _toggleChild(child.categoryId),
                );
              }).toList(),
            ),
        ],
      ],
    );
  }
}
