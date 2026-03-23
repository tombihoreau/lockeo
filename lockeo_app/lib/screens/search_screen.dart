import 'package:flutter/material.dart';
import '../screens/filters_screen.dart';
import '../widgets/search_header.dart';
import '../widgets/search_results_grid.dart';
import 'package:lockeo_app/theme/app_text_styles.dart';
import 'package:lockeo_app/theme/app_colors.dart';

class SearchPage extends StatefulWidget {
  final String? initialQuery;
  final List<int>? initialCategoryIds;
  final String initialSortBy;
  final bool favoritesOnly;

  const SearchPage({
    super.key,
    this.initialQuery,
    this.initialCategoryIds,
    this.initialSortBy = "Prix",
    this.favoritesOnly = false,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  String _draftQuery = '';
  String _submittedQuery = '';
  int _resultCount = 0;
  List<int> _selectedCategories = [];
  RangeValues? _priceRange;
  bool get _hasActiveFilters {
    return _selectedCategories.isNotEmpty || _priceRange != null;
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery ?? '');
    _draftQuery = widget.initialQuery ?? '';
    _submittedQuery = widget.initialQuery ?? '';
    _selectedCategories = widget.initialCategoryIds ?? [];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  void _submitSearch([String? value]) {
    final nextQuery = (value ?? _controller.text).trim();
    setState(() {
      _draftQuery = nextQuery;
      _submittedQuery = nextQuery;
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
            focusNode: _focusNode,
            initialQuery: _submittedQuery,
            onChanged: (value) => setState(() => _draftQuery = value),
            onSubmitted: (value) => _submitSearch(value),
            onSearch: (value) => _submitSearch(value),
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
                                searchQuery: _draftQuery,
                                initialFilters: {
                                  'categories': _selectedCategories,
                                  'priceRange': _priceRange,
                                },
                              ),
                            ),
                          );

                          if (result != null) {
                            setState(() {
                              _selectedCategories = List<int>.from(
                                result['categories'] ?? [],
                              );
                              _priceRange =
                                  result['priceRange'] as RangeValues?;
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
                            Icon(
                              Icons.chevron_right,
                              color: AppColors.blue800,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 🧩 Grille
                  Expanded(
                    child: SearchResultsGrid(
                      key: ValueKey(
                        "$_submittedQuery-$_selectedCategories-$_priceRange",
                      ),
                      searchQuery: _submittedQuery,
                      selectedCategories: _selectedCategories,
                      priceRange: _priceRange,
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
