import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/category.dart';
import '../services/local_data_service.dart';
import '../services/category_service.dart';
import '../theme/app_colors.dart';
import 'package:lockeo_app/theme/app_text_styles.dart';
import '../screens/search_screen.dart';

class CategoriesScreen extends StatelessWidget {
  final int? parentCategoryId;
  final String? title;

  const CategoriesScreen({super.key, this.parentCategoryId, this.title});

  IconData _iconForLabel(String label) {
    final normalized = label.toLowerCase();
    if (normalized.contains('vélo') || normalized.contains('velo')) {
      return LucideIcons.bike;
    }
    if (normalized.contains('sport')) return LucideIcons.dumbbell;
    if (normalized.contains('bricolage')) return LucideIcons.hammer;
    if (normalized.contains('maison')) return LucideIcons.home;
    if (normalized.contains('informatique')) return LucideIcons.monitor;
    if (normalized.contains('jardin')) return LucideIcons.trees;
    if (normalized.contains('randonnée')) return LucideIcons.mountain;
    return LucideIcons.box;
  }

  Future<List<Category>> _loadCategories() async {
    final remoteService = CategoryService();
    final localService = LocalDataService();

    try {
      final remote = await remoteService.fetchCategories();
      if (remote.isNotEmpty) return remote;
      return await localService.loadCategories();
    } catch (_) {
      return await localService.loadCategories();
    }
  }

  bool _hasChildren(List<Category> all, int parentId) =>
      all.any((c) => c.parentId == parentId);

  List<Category> _visibleCategories(List<Category> all) {
    if (parentCategoryId == null) {
      return all.where((c) => c.isParent).toList()
        ..sort((a, b) => a.label.compareTo(b.label));
    }
    return all.where((c) => c.parentId == parentCategoryId).toList()
      ..sort((a, b) => a.label.compareTo(b.label));
  }

  void _openCategory(
    BuildContext context,
    Category category,
    List<Category> all,
  ) {
    final hasChildren = _hasChildren(all, category.categoryId);

    if (hasChildren) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CategoriesScreen(
            parentCategoryId: category.categoryId,
            title: category.label,
          ),
        ),
      );
      return;
    }

    // feuille -> search filtrée sur l'enfant
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchPage(
          initialQuery: "",
          initialCategoryIds: [category.categoryId],
        ),
      ),
    );
  }

  void _openAllResultsForParent(BuildContext context, List<Category> all) {
    if (parentCategoryId == null) return;

    final childrenIds = all
        .where((c) => c.parentId == parentCategoryId)
        .map((c) => c.categoryId)
        .toList();

    final ids = <int>[parentCategoryId!, ...childrenIds];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchPage(initialQuery: "", initialCategoryIds: ids),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pageTitle = title ?? "Toutes nos catégories";
    final isChildrenPage = parentCategoryId != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          pageTitle,
          style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Category>>(
          future: _loadCategories(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Aucune catégorie disponible"));
            }

            final all = snapshot.data!;
            final categories = _visibleCategories(all);

            if (categories.isEmpty) {
              return const Center(child: Text("Aucune sous-catégorie"));
            }

            final itemCount = isChildrenPage
                ? categories.length + 1
                : categories.length;

            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              itemCount: itemCount,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: AppColors.cape300),
              itemBuilder: (context, index) {
                if (isChildrenPage && index == 0) {
                  return InkWell(
                    onTap: () => _openAllResultsForParent(context, all),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.blue50,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              LucideIcons.layoutGrid,
                              color: AppColors.blue900,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              "Voir tous nos résultats",
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.blue900,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: AppColors.blue900,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final category = categories[isChildrenPage ? index - 1 : index];
                return InkWell(
                  onTap: () => _openCategory(context, category, all),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        // ✅ Parents : icône, Enfants : pas d’icône
                        if (!isChildrenPage) ...[
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.blue50,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              _iconForLabel(category.label),
                              color: AppColors.blue900,
                            ),
                          ),
                          const SizedBox(width: 16),
                        ] else ...[
                          // alignement texte pour que ça ressemble à ton mock
                          const SizedBox(width: 4),
                        ],

                        Expanded(
                          child: Text(
                            category.label,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.blue900,
                            ),
                          ),
                        ),

                        Icon(
                          Icons.chevron_right,
                          color: AppColors.blue900,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
