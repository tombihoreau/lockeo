import 'package:flutter/material.dart';
import '../widgets/product_grid.dart';
import '../screens/filters_screen.dart';
import '../widgets/search_header.dart';

class SearchPage extends StatefulWidget {
  final String? initialQuery;
  const SearchPage({super.key, this.initialQuery});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  String _query = '';
  int _resultCount = 0;
  List<String> _selectedCategories = [];
  double _maxDistance = 20;
  RangeValues _priceRange = const RangeValues(5, 10);
  String _sortBy = "Prix"; 

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery ?? '');
    _query = widget.initialQuery ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          SearchHeader(
            initialQuery: _query,
            onChanged: (value) => setState(() => _query = value),
            onBack: () => Navigator.pop(context),
          ),

          // 🧱 Résultats
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🏷️ Ligne titre + filtres
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🧱 Bloc gauche : Nos résultats
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 30), // 👈 Décalage ciblé
                          const Text(
                            "Nos résultats",
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "$_resultCount résultat${_resultCount > 1 ? 's' : ''}",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(), // 🧩 pousse le reste à droite
                      // 🔹 Bloc droit : Filtres
                      GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FiltersPage(
                                searchQuery: _query, // 👈 nouvelle propriété
                                initialFilters: {
                                  'categories': _selectedCategories,
                                  'maxDistance': _maxDistance,
                                  'priceRange': _priceRange,
                                  'sortBy': _sortBy,
                                },
                              ),
                            ),
                          );

                          if (result != null) {
                            setState(() {
                              _selectedCategories = List<String>.from(result['categories'] ?? []);
                              _maxDistance = result['maxDistance'];
                              _priceRange = result['priceRange'];
                              _sortBy = result['sortBy'];
                            });

                            // 🔄 ici tu pourras filtrer ta ProductGrid
                          }
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Filtres",
                              style: TextStyle(color: Color(0xFF00434A)),
                            ),
                            Icon(Icons.chevron_right, color: Color(0xFF00434A)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 🧩 Grille
                  Expanded(
                    child: ProductGrid(
                      searchQuery: _query,
                      selectedCategories: _selectedCategories,
                      maxDistance: _maxDistance,
                      priceRange: _priceRange,
                      sortBy: _sortBy,
                      onCountChanged: (count) {
                        if (count != _resultCount) {
                          setState(() {
                            _resultCount = count;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
