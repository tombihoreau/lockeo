import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import 'package:lockeo_app/utils/app_navigator.dart';
import '../services/local_data_service.dart';
import '../widgets/button.dart';
import '../widgets/categories_selector.dart';
import 'package:lockeo_app/theme/app_text_styles.dart';
import 'package:lockeo_app/theme/app_colors.dart';

// Si tu as un model Product, importe-le.
// import '../models/product.dart';

class FiltersPage extends StatefulWidget {
  final Map<String, dynamic>? initialFilters;
  final String? searchQuery;

  const FiltersPage({super.key, this.initialFilters, this.searchQuery});

  @override
  State<FiltersPage> createState() => _FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage> {
  final dataService = LocalDataService();
  final _categoryService = CategoryService();

  List<Category> _categories = [];
  List<int> _selectedCategories = [];

  double _maxDistance = 100;

  // ✅ nouvelle logique prix
  double _minPossiblePrice = 0;
  double _maxPossiblePrice = 100;
  RangeValues _selectedPriceRange = const RangeValues(0, 100);

  DateTimeRange? _selectedDateRange;
  bool _favoritesOnly = false;

  bool _isLoading = true;
  late TextEditingController _controller;

  static const _pageBg = Color(0xFFF5F7FA);

  Text _h3(String text) => Text(
    text,
    style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
  );

  BoxDecoration _inputDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
  );

  bool get _isFullPriceRangeSelected =>
      _selectedPriceRange.start <= _minPossiblePrice &&
      _selectedPriceRange.end >= _maxPossiblePrice;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery ?? '');
    _init();
  }

  Future<void> _init() async {
    // 1) charge catégories
    final cats = await _loadCategories();

    // 2) charge produits pour min/max prix
    final priceBounds = await _loadPriceBounds();

    if (!mounted) return;

    // 3) hydrate avec initialFilters
    final f = widget.initialFilters;

    // valeurs par défaut basées sur min/max réels
    double minP = priceBounds.$1;
    double maxP = priceBounds.$2;

    RangeValues defaultRange = RangeValues(minP, maxP);

    List<int> initialCats = [];
    double initialMaxDistance = 100;
    String initialSortBy = "Prix";
    DateTimeRange? initialDateRange;
    RangeValues initialPriceRange = defaultRange;
    bool initialFavoritesOnly = false;

    if (f != null) {
      initialCats = List<int>.from(f['categories'] ?? []);

      final md = f['maxDistance'];
      if (md is num) initialMaxDistance = md.toDouble();

      initialSortBy = (f['sortBy'] ?? "Prix").toString();
      initialFavoritesOnly = f['favoritesOnly'] == true;

      final dr = f['selectedDateRange'];
      if (dr != null && dr is Map && dr['start'] != null && dr['end'] != null) {
        try {
          initialDateRange = DateTimeRange(
            start: DateTime.parse(dr['start']),
            end: DateTime.parse(dr['end']),
          );
        } catch (_) {
          initialDateRange = null;
        }
      }

      // ✅ si SearchPage a renvoyé null => pas de filtre => on prend full range
      final pr = f['priceRange'];
      if (pr is RangeValues) {
        // on clamp au cas où les bornes ont changé
        initialPriceRange = RangeValues(
          pr.start.clamp(minP, maxP),
          pr.end.clamp(minP, maxP),
        );
      } else {
        initialPriceRange = defaultRange;
      }
    }

    setState(() {
      _categories = cats;
      _selectedCategories = initialCats;

      _maxDistance = initialMaxDistance;
      _selectedDateRange = initialDateRange;
      _favoritesOnly = initialFavoritesOnly;

      _minPossiblePrice = minP;
      _maxPossiblePrice = maxP;
      _selectedPriceRange = initialPriceRange;

      _isLoading = false;
    });
  }

  Future<List<Category>> _loadCategories() async {
    try {
      final remote = await _categoryService.fetchCategories();
      if (remote.isNotEmpty) return remote;
    } catch (_) {
      // Fallback local en environnement sans backend.
    }

    return dataService.loadCategories();
  }

  // ---- À ADAPTER si ton champ prix n'est pas pricePerDay
  double? _getPricePerDay(dynamic product) {
    try {
      final v = product.price;
      if (v is num) return v.toDouble();
    } catch (_) {}

    try {
      final v = product.price;
      if (v is num) return v.toDouble();
    } catch (_) {}

    return null;
  }

  Future<(double, double)> _loadPriceBounds() async {
    // Si ton service renvoie List<Product>, garde tel quel.
    final products = await dataService.loadProducts();

    double? minP;
    double? maxP;

    for (final p in products) {
      final price = _getPricePerDay(p);
      if (price == null) continue;

      minP = (minP == null) ? price : (price < minP ? price : minP);
      maxP = (maxP == null) ? price : (price > maxP ? price : maxP);
    }

    // fallback si aucun prix trouvé
    minP ??= 0;
    maxP ??= 100;

    // évite RangeSlider min==max
    if (minP == maxP) {
      maxP = minP + 1;
    }

    // arrondis visuels si tu veux (optionnel)
    minP = minP.floorToDouble();
    maxP = maxP.ceilToDouble();

    return (minP, maxP);
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(2030),
      initialDateRange:
          _selectedDateRange ??
          DateTimeRange(start: now, end: now.add(const Duration(days: 1))),
    );

    if (!mounted) return;
    if (picked != null) setState(() => _selectedDateRange = picked);
  }

  String _formatDateRange(DateTimeRange range) {
    String d(DateTime x) => "${x.day}/${x.month}/${x.year}";
    return "${d(range.start)} — ${d(range.end)}";
  }

  String _money(double v) => "${v.round()}€";

  void _applyAndClose() {
    Navigator.pop(context, {
      'categories': _selectedCategories,
      'maxDistance': _maxDistance >= 100 ? null : _maxDistance,
      // ✅ renvoie null si full range => ProductGrid ne filtre pas
      'priceRange': _isFullPriceRangeSelected ? null : _selectedPriceRange,
      'sortBy': _sortBy,
      'favoritesOnly': _favoritesOnly,
      'selectedDateRange': _selectedDateRange == null
          ? null
          : {
              'start': _selectedDateRange!.start.toIso8601String(),
              'end': _selectedDateRange!.end.toIso8601String(),
            },
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,

      appBar: AppBar(
        backgroundColor: _pageBg,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => AppNavigator.back(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        title: Text(
          "Filtres",
          style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
        ),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1) Localisation
                  _h3("Votre localisation"),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: _inputDecoration(),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Leon Bourgeois, Rennes",
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.my_location, color: AppColors.textPrimary),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // 2) Distance
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _h3("Distance"),
                      Text(
                        "${_maxDistance.round()}km",
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primaryBlue,
                      inactiveTrackColor: Colors.grey.shade300,
                      thumbColor: AppColors.primaryBlue,
                      overlayColor: AppColors.primaryBlue.withValues(
                        alpha: 0.15,
                      ),
                    ),
                    child: Slider(
                      value: _maxDistance,
                      min: 0,
                      max: 100,
                      divisions: 10,
                      onChanged: (v) => setState(() => _maxDistance = v),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // 3) Date
                  _h3("Date"),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickDateRange,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: _inputDecoration(),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedDateRange == null
                                  ? "Choisir une période"
                                  : _formatDateRange(_selectedDateRange!),
                              style: AppTextStyles.label.copyWith(
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.calendar_today,
                            color: AppColors.textPrimary,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // 4) Trier par
                  _h3("Trier par"),
                  const SizedBox(height: 8),
                  Container(
                    decoration: _inputDecoration(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _sortBy,
                        isExpanded: true,
                        icon: Icon(
                          Icons.expand_more,
                          color: AppColors.primaryBlue,
                        ),
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        items: const [
                          DropdownMenuItem(value: "Prix", child: Text("Prix")),
                          DropdownMenuItem(
                            value: "Distance",
                            child: Text("Distance"),
                          ),
                          DropdownMenuItem(
                            value: "Popularité",
                            child: Text("Popularité"),
                          ),
                          DropdownMenuItem(
                            value: "Nouveautés",
                            child: Text("Nouveautés"),
                          ),
                        ],
                        onChanged: (val) {
                          if (val == null) return;
                          setState(() => _sortBy = val);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // 5) Favoris
                  _h3("Favoris"),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: _inputDecoration(),
                    child: Row(
                      children: [
                        Icon(
                          _favoritesOnly
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: _favoritesOnly
                              ? AppColors.primaryRed
                              : AppColors.textGrey,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Favoris uniquement",
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Switch.adaptive(
                          value: _favoritesOnly,
                          activeColor: AppColors.primaryRed,
                          onChanged: (value) {
                            setState(() => _favoritesOnly = value);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // 6) Prix (nouveau fonctionnement)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _h3("Prix par jour"),
                      Text(
                        "${_money(_selectedPriceRange.start)} - ${_money(_selectedPriceRange.end)}",
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primaryBlue,
                      inactiveTrackColor: Colors.grey.shade300,
                      thumbColor: AppColors.primaryBlue,
                      overlayColor: AppColors.primaryBlue.withValues(
                        alpha: 0.15,
                      ),
                      rangeThumbShape: const RoundRangeSliderThumbShape(
                        enabledThumbRadius: 12,
                      ),
                    ),
                    child: RangeSlider(
                      values: _selectedPriceRange,
                      min: _minPossiblePrice,
                      max: _maxPossiblePrice,
                      divisions: (_maxPossiblePrice - _minPossiblePrice)
                          .round()
                          .clamp(1, 200),
                      onChanged: (values) {
                        setState(() => _selectedPriceRange = values);
                      },
                    ),
                  ),

                  // ✅ bornes min/max visuelles en bas (image 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _money(_minPossiblePrice),
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.textGrey,
                          ),
                        ),
                        Text(
                          _money(_maxPossiblePrice),
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  _h3("Nos catégories"),

                  const SizedBox(height: 10),
                  CategoriesSelector(
                    categories: _categories,
                    selectedCategories: _selectedCategories,
                    onChanged: (updatedList) =>
                        setState(() => _selectedCategories = updatedList),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),

      bottomNavigationBar: Container(
        color: Colors.white,
        alignment: Alignment.center,
        height: 100,
        child: SizedBox(
          width: 300,
          child: CustomButton(
            text: "Afficher tous les résultats",
            onPressed: _applyAndClose,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
