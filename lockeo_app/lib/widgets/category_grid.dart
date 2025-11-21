import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/local_data_service.dart';
import '../services/category_service.dart';
import 'category_card.dart';

class CategoryGrid extends StatelessWidget {
  final int? maxItems;

  const CategoryGrid({super.key, this.maxItems});

  @override
  Widget build(BuildContext context) {
    final remoteService = CategoryService();
    final localService = LocalDataService();

    Future<List<Category>> load() async {
      try {
        final remote = await remoteService.fetchCategories();
        if (remote.isNotEmpty) return remote;
        // Fallback si liste vide
        return await localService.loadCategories();
      } catch (_) {
        // Fallback sur les données embarquées
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

        final categories = maxItems != null ? snapshot.data!.take(maxItems!).toList() : snapshot.data!;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: categories.map((category) {
            return SizedBox(
              width: (MediaQuery.of(context).size.width - 16 * 2 - 12) / 2,
              child: CategoryCard(
                name: category.label,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
