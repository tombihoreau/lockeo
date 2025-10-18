import 'package:flutter/material.dart';
import '../services/local_data_service.dart';
import '../widgets/product_grid.dart';

class ProductsScreen extends StatelessWidget {
  final LocalDataService dataService = LocalDataService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Produits disponibles"),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: ProductGrid(), 
      ),
    );
  }
}
