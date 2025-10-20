import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/local_data_service.dart';
import 'category_card.dart';

class CategoryGrid extends StatelessWidget {
  final int? maxItems;

  const CategoryGrid({super.key, this.maxItems});

  @override
  Widget build(BuildContext context) {
    final dataService = LocalDataService();

    return FutureBuilder<List<Category>>(
      future: dataService.loadCategories(),
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
                iconName: category.iconName,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
