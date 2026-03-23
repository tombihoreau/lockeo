import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/offerDraft.dart';
import '../../services/category_service.dart';
import '../../services/create_offer_service.dart';
import '../../models/category.dart';
import '../../services/local_data_service.dart';
import '../../widgets/button.dart';
import '../../widgets/category_card.dart';
import '../../widgets/selected_photo_image.dart';
import 'create_offer_end_screen.dart';
import 'package:lockeo_app/theme/app_colors.dart';
import 'package:lockeo_app/theme/app_text_styles.dart';

class CreateOfferSummaryScreen extends StatefulWidget {
  final OfferDraft draft;

  const CreateOfferSummaryScreen({super.key, required this.draft});

  @override
  State<CreateOfferSummaryScreen> createState() =>
      _CreateOfferSummaryScreenState();
}

class _CreateOfferSummaryScreenState extends State<CreateOfferSummaryScreen> {
  List<Category> _allCategories = [];
  final _createOfferService = CreateOfferService();
  final _categoryService = CategoryService();

  bool _acceptedCgu = false;
  bool _publishing = false;

  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadCats();
  }

  Future<void> _loadCats() async {
    try {
      final remoteCategories = await _categoryService.fetchCategories();
      if (remoteCategories.isNotEmpty) {
        _allCategories = remoteCategories;
      } else {
        _allCategories = await LocalDataService().loadCategories();
      }
    } catch (_) {
      _allCategories = await LocalDataService().loadCategories();
    }

    if (mounted) setState(() {});
  }

  Future<void> _saveAndContinue() async {
    if (!_acceptedCgu || _publishing) return;

    setState(() => _publishing = true);
    try {
      final createdOffer = await _createOfferService.createOffer(widget.draft);
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CreateOfferEndScreen(
            offerTitle: widget.draft.title ?? '',
            offerDescription: widget.draft.description ?? '',
            offerImagePath: widget.draft.photos.isNotEmpty
                ? widget.draft.photos[0]
                : '',
            offerCount: 1,
            offerId: createdOffer.offerId,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la publication: $e")),
      );
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  // 1 = lundi ... 7 = dimanche
  bool _isAvailableWeekDay(DateTime day) {
    final available = widget.draft.availableWeekDays ?? <int>[];
    if (available.isEmpty) return true; // fallback
    return available.contains(day.weekday);
  }

  bool _isUnavailableDate(DateTime day) {
    final list = widget.draft.unavailableDates ?? <DateTime>[];
    final set = list.map(_dateOnly).toSet();
    return set.contains(_dateOnly(day));
  }

  bool _isEnabledDay(DateTime day) {
    // Optionnel : empêcher le passé
    final today = _dateOnly(DateTime.now());
    if (_dateOnly(day).isBefore(today)) return false;

    if (_isUnavailableDate(day)) return false;
    if (!_isAvailableWeekDay(day)) return false;
    return true;
  }

  HeaderStyle get _headerStyle {
    return HeaderStyle(
      titleCentered: true,
      formatButtonVisible: false,
      leftChevronIcon: const Icon(Icons.chevron_left, color: Colors.black),
      rightChevronIcon: const Icon(Icons.chevron_right, color: Colors.black),
      titleTextStyle: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
      headerPadding: const EdgeInsets.symmetric(vertical: 8),
    );
  }

  CalendarStyle get _calendarStyle {
    return CalendarStyle(
      cellMargin: EdgeInsets.zero,
      cellPadding: EdgeInsets.zero,

      rangeHighlightColor: AppColors.primaryBlue.withValues(alpha: 0.15),
      rangeHighlightScale: 1.0,

      withinRangeDecoration: const BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.rectangle,
      ),

      todayDecoration: BoxDecoration(
        color: Colors.grey.shade300,
        shape: BoxShape.circle,
      ),

      defaultTextStyle: AppTextStyles.label.copyWith(
        color: AppColors.textPrimary,
      ),
      weekendTextStyle: AppTextStyles.label.copyWith(
        color: AppColors.textPrimary,
      ),
      outsideTextStyle: AppTextStyles.label.copyWith(
        color: Colors.grey.shade400,
      ),
      disabledTextStyle: AppTextStyles.label.copyWith(
        color: Colors.grey.shade400,
      ),
      todayTextStyle: AppTextStyles.label.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _section({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }

  Widget _photoTile(String? path) {
    if (path == null || path.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.image_outlined, color: Colors.grey.shade400),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SelectedPhotoImage(path: path, fit: BoxFit.cover),
    );
  }

  Widget _buildPhotoLayout(List<String> photos) {
    final main = photos.isNotEmpty ? photos[0] : null;
    final small = <String?>[
      photos.length > 1 ? photos[1] : null,
      photos.length > 2 ? photos[2] : null,
      photos.length > 3 ? photos[3] : null,
      photos.length > 4 ? photos[4] : null,
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main photo
        Expanded(
          flex: 1,
          child: AspectRatio(aspectRatio: 1, child: _photoTile(main)),
        ),
        const SizedBox(width: 10),
        // 2x2 small grid
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _photoTile(small[0]),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _photoTile(small[1]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _photoTile(small[2]),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _photoTile(small[3]),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.draft;

    final selectedCategories = _allCategories
        .where((cat) => d.categories.contains(cat.categoryId))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Icon(Icons.chevron_left, color: Colors.black),
            ),
          ),
        ),
        centerTitle: false,
        title: Text(
          "Mon annonce",
          style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
        ),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.only(right: 12),
        //     child: TextButton(
        //       onPressed: () => Navigator.pop(context), // retour vers les steps
        //       child: Text(
        //         "Modifier",
        //         style: AppTextStyles.caption.copyWith(
        //           color: AppColors.primaryRed,
        //           fontWeight: FontWeight.w700,
        //         ),
        //       ),
        //     ),
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Vos photos", style: AppTextStyles.h3),
            const SizedBox(height: 12),
            _buildPhotoLayout(d.photos),
            const SizedBox(height: 24),

            Text(
              d.title ?? "Titre de l'annonce",
              style: AppTextStyles.h1.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            // Localisation
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: Colors.black,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    d.location ?? '',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Prix
            Row(
              children: [
                const Icon(
                  Icons.savings_outlined,
                  color: Colors.black,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  "${(d.pricePerDay ?? 0).toStringAsFixed(0)}€/jour",
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                if (d.price3Days != null && d.price3Days! > 0) ...[
                  _PriceChip(
                    text: "${d.price3Days!.toStringAsFixed(0)}€ pour 3 jours",
                  ),
                  const SizedBox(width: 8),
                ],
                if (d.pricePerWeek != null && d.pricePerWeek! > 0)
                  _PriceChip(
                    text: "${d.pricePerWeek!.toStringAsFixed(0)}€ pour 7 jours",
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Etat
            Row(
              children: [
                const Icon(
                  Icons.bookmark_border,
                  color: Colors.black,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    d.state ?? "Bon état",
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text("Description", style: AppTextStyles.label),
            const SizedBox(height: 4),
            Text(
              d.description ?? "Aucune description",
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            ),

            const SizedBox(height: 12),

            Text("Catégories", style: AppTextStyles.label),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: selectedCategories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CategoryCard(name: category.label),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            Text("Disponibilité de l’article", style: AppTextStyles.h3),
            const SizedBox(height: 12),
            _section(
              child: TableCalendar(
                locale: 'fr_FR',
                firstDay: DateTime.now().subtract(const Duration(days: 0)),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.monday,
                headerStyle: _headerStyle,
                calendarStyle: _calendarStyle,
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: AppTextStyles.caption.copyWith(
                    color: AppColors.textGrey800,
                  ),
                  weekendStyle: AppTextStyles.caption.copyWith(
                    color: AppColors.textGrey800,
                  ),
                ),
                enabledDayPredicate: (day) => _isEnabledDay(day),
                onPageChanged: (focusedDay) {
                  setState(() => _focusedDay = focusedDay);
                },
                // Affichage des indispos même si le jour est "disabled"
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, focusedDay) {
                    final isOut =
                        day.month != focusedDay.month; // hors mois courant
                    final isUnavailable = _isUnavailableDate(day);
                    final isEnabled = _isEnabledDay(day);

                    if (isUnavailable) {
                      return Center(
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryRed,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "${day.day}",
                            style: AppTextStyles.label.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    }

                    if (!isEnabled || isOut) {
                      return Center(
                        child: Text(
                          "${day.day}",
                          style: AppTextStyles.label.copyWith(
                            color: Colors.grey.shade400,
                          ),
                        ),
                      );
                    }

                    return null; // style par défaut
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            InkWell(
              onTap: () => setState(() => _acceptedCgu = !_acceptedCgu),
              borderRadius: BorderRadius.circular(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: Checkbox(
                      value: _acceptedCgu,
                      onChanged: (_) =>
                          setState(() => _acceptedCgu = !_acceptedCgu),
                      activeColor: AppColors.primaryBlue,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "En publiant cette annonce je certifie que l’équipement est fonctionnelle et j’accepte les CGU",
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 54,
            child: CustomButton(
              text: _publishing ? "Publication..." : "Publier mon annonce",
              onPressed: (_acceptedCgu && !_publishing)
                  ? () {
                      _saveAndContinue();
                    }
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _PriceChip extends StatelessWidget {
  final String text;
  const _PriceChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryBlue, width: 1),
        borderRadius: BorderRadius.circular(999),
        color: AppColors.blue50,
      ),
      child: Text(
        text,
        style: AppTextStyles.label.copyWith(color: AppColors.primaryBlue),
      ),
    );
  }
}
