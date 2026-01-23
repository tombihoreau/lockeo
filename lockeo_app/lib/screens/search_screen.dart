import 'package:flutter/material.dart';
import '../widgets/product_grid.dart';
import '../screens/filters_screen.dart';
import '../widgets/search_header.dart';
import 'package:lockeo_app/theme/app_text_styles.dart';
import 'package:lockeo_app/theme/app_colors.dart';

class SearchPage extends StatefulWidget {
  final String? initialQuery;
  final List<int>? initialCategoryIds;
  const SearchPage({super.key, this.initialQuery, this.initialCategoryIds});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  String _query = '';
  int _resultCount = 0;
  List<int> _selectedCategories = [];
  double _maxDistance = 20;
  RangeValues? _priceRange;
  String _sortBy = "Prix";
  bool get _hasActiveFilters {
    return _selectedCategories.isNotEmpty ||
        _maxDistance != 20 ||
        _priceRange != null ||
        _sortBy != "Prix";
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery ?? '');
    _query = widget.initialQuery ?? '';
    _selectedCategories = widget.initialCategoryIds ?? [];

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
            controller: _controller,
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
                          const SizedBox(height: 30),
                          Text(
                            "Nos résultats",
                            style: AppTextStyles.h2.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "$_resultCount résultat${_resultCount > 1 ? 's' : ''}",
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.textGrey,
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
                              _selectedCategories = List<int>.from(
                                result['categories'] ?? [],
                              );
                              _maxDistance = (result['maxDistance'] as num)
                                  .toDouble();
                              _priceRange =
                                  result['priceRange'] as RangeValues?;

                              _sortBy = (result['sortBy'] ?? "Prix").toString();
                            });
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _hasActiveFilters
                                  ? "Modifier mes filtres"
                                  : "Nos filtres",
                              style: AppTextStyles.link.copyWith(
                                color: AppColors.blue800,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            Icon(Icons.chevron_right, color: AppColors.blue800),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 🧩 Grille
                  Expanded(
                    child: ProductGrid(
                      key: ValueKey(
                        "$_query-$_selectedCategories-$_maxDistance-$_priceRange-$_sortBy",
                      ),
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
