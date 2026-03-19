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
  List<Category> get _parents =>
      widget.categories.where((c) => c.isParent).toList()
        ..sort((a, b) => a.label.compareTo(b.label));

  List<Category> _childrenOf(int parentId) =>
      widget.categories.where((c) => c.parentId == parentId).toList()
        ..sort((a, b) => a.label.compareTo(b.label));

  int? _firstSelectedParentId() {
    final byId = {
      for (final category in widget.categories) category.categoryId: category,
    };

    for (final categoryId in widget.selectedCategories) {
      final category = byId[categoryId];
      if (category?.isParent == true) {
        return category!.categoryId;
      }
    }

    for (final categoryId in widget.selectedCategories) {
      final category = byId[categoryId];
      if (category?.isChild == true) {
        return category!.parentId;
      }
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    _expandedParentId = _firstSelectedParentId();
  }

  @override
  void didUpdateWidget(covariant CategoriesSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    final selectedParentId = _firstSelectedParentId();
    if (selectedParentId != _expandedParentId) {
      _expandedParentId = selectedParentId;
    }
  }

  void _toggleParent(Category parent) {
    if (!widget.selectable) return;

    final childIds = _childrenOf(
      parent.categoryId,
    ).map((child) => child.categoryId).toSet();
    final updated = List<int>.from(widget.selectedCategories);
    final isParentActive =
        updated.contains(parent.categoryId) || updated.any(childIds.contains);

    updated.removeWhere(
      (id) => id == parent.categoryId || childIds.contains(id),
    );

    if (!isParentActive) {
      updated.add(parent.categoryId);
      updated.sort();
      setState(() => _expandedParentId = parent.categoryId);
    } else if (_expandedParentId == parent.categoryId) {
      setState(() => _expandedParentId = null);
    }

    widget.onChanged(updated);
  }

  void _toggleChild(Category child) {
    if (!widget.selectable) return;

    final parentId = child.parentId;
    if (parentId == null) return;

    final updated = List<int>.from(widget.selectedCategories);
    if (!updated.contains(parentId)) {
      updated.add(parentId);
    }

    if (updated.contains(child.categoryId)) {
      updated.remove(child.categoryId);
    } else {
      updated.add(child.categoryId);
    }

    updated.sort();
    setState(() => _expandedParentId = parentId);
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
            final childIds = _childrenOf(
              parent.categoryId,
            ).map((child) => child.categoryId).toSet();
            final isSelected =
                widget.selectedCategories.contains(parent.categoryId) ||
                widget.selectedCategories.any(childIds.contains);

            return _chip(
              label: parent.label,
              isSelected: isSelected,
              onTap: () => _toggleParent(parent),
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
                onTap: () => _toggleChild(child),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
