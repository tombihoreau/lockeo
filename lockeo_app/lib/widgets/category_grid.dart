import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/local_data_service.dart';
import '../services/category_service.dart';
import '../screens/search_screen.dart';
import 'category_card.dart';

class CategoryGrid extends StatelessWidget {
  final int? maxItems;

  const CategoryGrid({super.key, this.maxItems});

  List<Category> _topLevel(List<Category> all) =>
      all.where((c) => c.parentId == null).toList();

  List<int> _idsForParentAndChildren(List<Category> all, int parentId) {
    final childrenIds = all
        .where((c) => c.parentId == parentId)
        .map((c) => c.categoryId)
        .toList();

    return <int>[parentId, ...childrenIds];
  }

  void _openSearchForParent(BuildContext context, Category parent, List<Category> all) {
    final ids = _idsForParentAndChildren(all, parent.categoryId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchPage(
          initialQuery: "",
          initialCategoryIds: ids,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remoteService = CategoryService();
    final localService = LocalDataService();

    Future<List<Category>> load() async {
      try {
        final remote = await remoteService.fetchCategories();
        if (remote.isNotEmpty) return remote;
        return await localService.loadCategories();
      } catch (_) {
        return await localService.loadCategories();
      }
    }

    return FutureBuilder<List<Category>>(
      future: load(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Erreur ou données introuvables"));
        }

        final all = snapshot.data!;
        var parents = _topLevel(all);

        if (maxItems != null) {
          parents = parents.take(maxItems!).toList();
        }

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: parents.map((parent) {
            return SizedBox(
              width: (MediaQuery.of(context).size.width - 16 * 2 - 12) / 2,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _openSearchForParent(context, parent, all),
                child: CategoryCard(
                  name: parent.label,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
