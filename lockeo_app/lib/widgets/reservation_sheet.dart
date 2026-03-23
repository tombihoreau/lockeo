import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:lockeo_app/screens/reservation_payment_screen.dart';
import 'package:lockeo_app/theme/app_text_styles.dart';
import 'package:lockeo_app/theme/app_colors.dart';
import '../widgets/button.dart';
import '../models/product.dart';
import '../models/product_detail.dart';
import '../services/products_service.dart';
import '../utils/rental_pricing.dart';

class ReservationSheet extends StatefulWidget {
  final int offerId;
  const ReservationSheet({super.key, required this.offerId});

  @override
  State<ReservationSheet> createState() => _ReservationSheetState();
}

class _ReservationSheetState extends State<ReservationSheet> {
  final _productsService = ProductsService();
  DateTime? startDate;
  DateTime? endDate;
  DateTime focusedDay = DateTime.now();
  Product? _product;
  ProductDetail? _detail;

  int get offerId => widget.offerId;
  bool get hasRange => startDate != null && endDate != null;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final detail = await _productsService.getOfferDetail(widget.offerId);
    final product = detail.product;

    if (!mounted) return;
    setState(() {
      _detail = detail;
      _product = product;
    });
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  bool isPastDate(DateTime day) {
    final now = DateTime.now();
    return day.isBefore(DateTime(now.year, now.month, now.day));
  }

  bool isUnavailableDate(DateTime day) {
    final normalizedDay = _dateOnly(day);

    for (final item in _detail?.unavailabilities ?? const []) {
      final start = _dateOnly(
        DateTime(
          item.startDateTime.year,
          item.startDateTime.month,
          item.startDateTime.day,
        ),
      );
      final end = _dateOnly(
        DateTime(
          item.endDateTime.year,
          item.endDateTime.month,
          item.endDateTime.day,
        ),
      );

      final isInRange =
          (normalizedDay.isAtSameMomentAs(start) ||
              normalizedDay.isAfter(start)) &&
          (normalizedDay.isAtSameMomentAs(end) || normalizedDay.isBefore(end));

      if (isInRange) {
        return true;
      }
    }

    return false;
  }

  bool _rangeHasUnavailableDate(DateTime start, DateTime end) {
    var current = _dateOnly(start);
    final last = _dateOnly(end);

    while (!current.isAfter(last)) {
      if (isUnavailableDate(current)) {
        return true;
      }
      current = current.add(const Duration(days: 1));
    }

    return false;
  }

  int get _selectedDays {
    if (!hasRange) return 0;
    return endDate!.difference(startDate!).inDays + 1;
  }

  double? get _estimatedRentalPrice {
    if (_product == null || !hasRange) return null;
    return RentalPricing.breakdownForProduct(
      _product!,
      _selectedDays,
    ).rentalPrice;
  }

  // ✅ ne sélectionner que start/end (sinon cercles partout)
  bool isSelected(DateTime day) {
    if (startDate == null) return false;
    if (endDate == null) return isSameDay(day, startDate);
    return isSameDay(day, startDate) || isSameDay(day, endDate);
  }

  void _onDaySelected(DateTime day, DateTime _) {
    final normalizedDay = _dateOnly(day);
    if (isPastDate(normalizedDay) || isUnavailableDate(normalizedDay)) {
      return;
    }

    setState(() {
      if (startDate == null || endDate == null) {
        startDate = normalizedDay;
        endDate = normalizedDay;
      } else if (isSameDay(startDate, endDate) &&
          normalizedDay.isAfter(startDate!)) {
        if (_rangeHasUnavailableDate(startDate!, normalizedDay)) {
          startDate = normalizedDay;
          endDate = normalizedDay;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "La plage sélectionnée contient des jours indisponibles.",
              ),
            ),
          );
        } else {
          endDate = normalizedDay;
        }
      } else {
        startDate = normalizedDay;
        endDate = normalizedDay;
      }
      focusedDay = normalizedDay;
    });
  }

  CalendarStyle get _calendarStyle {
    return CalendarStyle(
      // ✅ supprime les petits espaces entre cellules
      cellMargin: EdgeInsets.zero,
      cellPadding: EdgeInsets.zero,

      // ✅ barre continue (le fond du range)
      rangeHighlightColor: AppColors.primaryBlue.withValues(alpha: 0.15),
      rangeHighlightScale: 1.0,

      // ✅ on évite les rectangles “par case”
      withinRangeDecoration: const BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.rectangle,
      ),

      rangeStartDecoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        shape: BoxShape.circle,
      ),
      rangeEndDecoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        shape: BoxShape.circle,
      ),

      selectedDecoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        shape: BoxShape.circle,
      ),

      todayDecoration: BoxDecoration(
        color: Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      disabledTextStyle: const TextStyle(color: Colors.black54),
    );
  }

  @override
  Widget build(BuildContext context) {
    double bottomSize = 110;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cape300,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // CONTENU (scroll) — on met un padding bas pour ne pas passer sous le footer
                SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 20),
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom:
                          80 + bottomSize, // réserve pour le footer (simple)
                    ),
                    child: Column(
                      children: [
                        // HEADER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Choisir la durée de location",
                              style: AppTextStyles.h2.copyWith(
                                color: Colors.black,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // CALENDRIER
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          child: TableCalendar(
                            locale: 'fr_FR',
                            firstDay: _dateOnly(DateTime.now()),
                            lastDay: DateTime(2035),
                            focusedDay: focusedDay,
                            headerStyle: const HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                              titleTextStyle: AppTextStyles.h2,
                            ),
                            daysOfWeekStyle: const DaysOfWeekStyle(
                              weekendStyle: AppTextStyles.label,
                              weekdayStyle: AppTextStyles.label,
                            ),
                            enabledDayPredicate: (day) =>
                                !isPastDate(day) && !isUnavailableDate(day),
                            rangeSelectionMode: RangeSelectionMode.toggledOn,
                            rangeStartDay: startDate,
                            rangeEndDay: endDate,
                            selectedDayPredicate: isSelected,
                            onDaySelected: _onDaySelected,
                            calendarStyle: _calendarStyle,
                            calendarBuilders: CalendarBuilders(
                              disabledBuilder: (context, day, focusedDay) {
                                return Center(
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${day.day}',
                                      style: AppTextStyles.label.copyWith(
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // FOOTER — collé en bas, pleine largeur
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: bottomSize,
                    // ✅ collé au bas de l'écran (pas de padding parent)
                    padding: EdgeInsets.fromLTRB(24, 20, 20, 32),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      // ✅ bloc “collé bas” : coins arrondis uniquement en haut (optionnel)
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          hasRange && _estimatedRentalPrice != null
                              ? "Votre coût initial sera de ${_estimatedRentalPrice!.toStringAsFixed(2)}€"
                              : "Sélectionnez un ou plusieurs jours",
                          style: const TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 12),
                        CustomButton(
                          text: "Suivant",
                          onPressed: hasRange
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ReservationPaymentScreen(
                                        offerId: offerId,
                                        startDate: startDate!,
                                        endDate: endDate!,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
