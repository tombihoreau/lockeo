import 'package:flutter/material.dart';
import '../services/local_data_service.dart';
import '../models/category.dart';
import '../widgets/button.dart';
import '../widgets/search_header.dart';
import '../widgets/categories_selector.dart';

class FiltersPage extends StatefulWidget {
  final Map<String, dynamic>? initialFilters;
  final String? searchQuery;

  const FiltersPage({super.key, this.initialFilters, this.searchQuery});

  @override
  State<FiltersPage> createState() => _FiltersPageState();
}

class _FiltersPageState extends State<FiltersPage> {
  final dataService = LocalDataService();

  List<Category> _categories = [];
  List<int> _selectedCategories = [];
  double _maxDistance = 20;
  RangeValues? _priceRange;
  String _sortBy = "Prix";
  DateTime? _selectedDate;
  DateTimeRange? _selectedDateRange;
  bool _isLoading = true;
  bool _enablePriceFilter = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();

    final f = widget.initialFilters;
    if (f != null) {
      _selectedCategories = List<int>.from(f['categories'] ?? []);
      _maxDistance = f['maxDistance'];
      _priceRange = f['priceRange'];
      _sortBy = f['sortBy'] ?? "Prix";

      final dr = f['selectedDateRange'];

      if (f['priceRange'] != null) {
        _enablePriceFilter = true;
        _priceRange = f['priceRange'];
      } else {
        _enablePriceFilter = false;
        _priceRange = const RangeValues(0, 100);
      }
      if (dr != null && dr is Map && dr['start'] != null && dr['end'] != null) {
        try {
          _selectedDateRange = DateTimeRange(
            start: DateTime.parse(dr['start']),
            end: DateTime.parse(dr['end']),
          );
        } catch (_) {
          _selectedDateRange = null;
        }
      }
    }
  }

  Future<void> _loadCategories() async {
    final cats = await dataService.loadCategories();
    setState(() {
      _categories = cats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          SearchHeader(
            initialQuery: widget.searchQuery,
            onBack: () => Navigator.pop(context),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Filtres",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 🔹 Catégories
                        const Text(
                          "Nos catégories",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),

                        CategoriesSelector(
                          categories: _categories,
                          selectedCategories: _selectedCategories,
                          onChanged: (updatedList) {
                            setState(() => _selectedCategories = updatedList);
                          },
                        ),

                        const SizedBox(height: 30),

                        // 🔹 Localisation (retour à l'état précédent)
                        const Text(
                          "Votre localisation",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text(
                                  "Leon Bourgeois, Rennes",
                                  style: TextStyle(color: Colors.black87),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(
                                Icons.my_location,
                                color: Color(0xFF00434A),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // 🔹 Distance
                        const Text(
                          "Distance",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: const Color(0xFF00434A),
                            inactiveTrackColor: Colors.grey.shade300,
                            thumbColor: const Color(0xFF00434A),
                            overlayColor: const Color(
                              0xFF00434A,
                            ).withOpacity(0.2),
                          ),
                          child: Slider(
                            value: _maxDistance,
                            min: 0,
                            max: 100,
                            divisions: 10,
                            label: "${_maxDistance.round()} km",
                            onChanged: (v) => setState(() => _maxDistance = v),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // 🔹 Date (période)
                        const Text(
                          "Date",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            final now = DateTime.now();
                            final picked = await showDateRangePicker(
                              context: context,
                              firstDate: now,
                              lastDate: DateTime(2030),
                              initialDateRange:
                                  _selectedDateRange ??
                                  DateTimeRange(
                                    start: now,
                                    end: now.add(const Duration(days: 1)),
                                  ),
                            );
                            if (picked != null) {
                              setState(() => _selectedDateRange = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _selectedDateRange == null
                                      ? "Choisir une période"
                                      : "${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month}/${_selectedDateRange!.start.year} — ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}/${_selectedDateRange!.end.year}",
                                  style: const TextStyle(color: Colors.black87),
                                ),
                                const Icon(
                                  Icons.calendar_today,
                                  color: Color(0xFF00434A),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // 🔹 Trier par
                        const Text(
                          "Trier par",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _sortBy,
                              icon: const Icon(
                                Icons.expand_more,
                                color: Color(0xFF00434A),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: "Prix",
                                  child: Text("Prix"),
                                ),
                                DropdownMenuItem(
                                  value: "Distance",
                                  child: Text("Distance"),
                                ),
                                DropdownMenuItem(
                                  value: "Nouveautés",
                                  child: Text("Nouveautés"),
                                ),
                              ],
                              onChanged: (val) {
                                setState(() => _sortBy = val!);
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // 🔹 Prix
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Prix (en €)",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            Switch(
                              activeColor: const Color(0xFF00434A),
                              value: _enablePriceFilter,
                              onChanged: (val) {
                                setState(() {
                                  _enablePriceFilter = val;
                                  if (val && _priceRange == null) {
                                    _priceRange = const RangeValues(0, 100);
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        RangeSlider(
                          values:
                              _priceRange ??
                              const RangeValues(0, 100), 
                          min: 0,
                          max: 100,
                          divisions: 20,
                          labels: RangeLabels(
                            "${(_priceRange ?? const RangeValues(0, 100)).start.round()}€",
                            "${(_priceRange ?? const RangeValues(0, 100)).end.round()}€",
                          ),
                          activeColor: const Color(0xFF00434A),
                          onChanged: _enablePriceFilter
                              ? (values) {
                                  setState(() => _priceRange = values);
                                }
                              : null, // désactive le slider
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),

      // 🟠 Bouton sticky bas de page
      bottomNavigationBar: Container(
        color: Colors.white,
        alignment: Alignment.center,
        height: 100,
        child: SizedBox(
          width: 300,
          child: CustomButton(
            text: "Afficher tous les résultats",
            onPressed: () {
              Navigator.pop(context, {
                'categories': _selectedCategories,
                'maxDistance': _maxDistance,
                'priceRange': _enablePriceFilter ? _priceRange : null,
                'sortBy': _sortBy,
                'selectedDateRange': _selectedDateRange == null
                    ? null
                    : {
                        'start': _selectedDateRange!.start.toIso8601String(),
                        'end': _selectedDateRange!.end.toIso8601String(),
                      },
              });
            },
          ),
        ),
      ),
    );
  }
}
