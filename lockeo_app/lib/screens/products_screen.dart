import 'package:flutter/material.dart';
import '../services/local_data_service.dart';
import '../widgets/product_grid.dart';
import '../widgets/header.dart';

class ProductsScreen extends StatelessWidget {
  final LocalDataService dataService = LocalDataService();
  final String? searchQuery;

  ProductsScreen({super.key, this.searchQuery});

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Header(
            isHome: false,
            initialQuery: searchQuery,
          ),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: ProductGrid(
                searchQuery: searchQuery,
                shrinkWrap: false, 
              ),
            ),
          ),
        ],
      ),
    );
  }
}
