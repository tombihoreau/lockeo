import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/offerDraft.dart';
import '../../widgets/button.dart';
import 'create_offer_summary_screen.dart';
import 'package:lockeo_app/theme/app_colors.dart';
import 'package:lockeo_app/theme/app_text_styles.dart';

class CreateOfferStep3Screen extends StatefulWidget {
  final OfferDraft draft;

  const CreateOfferStep3Screen({super.key, required this.draft});

  @override
  State<CreateOfferStep3Screen> createState() => _CreateOfferStep3ScreenState();
}

class _CreateOfferStep3ScreenState extends State<CreateOfferStep3Screen> {
  // 1 = lundi ... 7 = dimanche
  final List<int> _allWeekDays = [1, 2, 3, 4, 5, 6, 7];

  late Set<int> _selectedWeekDays;
  late Set<DateTime> _unavailableDates;

  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();

    _selectedWeekDays = (widget.draft.availableWeekDays ?? []).toSet();
    _unavailableDates = (widget.draft.unavailableDates ?? [])
        .map(_dateOnly)
        .toSet();

    // Par défaut : lun->ven cochés (comme la maquette) si rien n’est défini
    if (_selectedWeekDays.isEmpty) {
      _selectedWeekDays = {1, 2, 3, 4, 5};
    }
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool get _allDaysSelected => _selectedWeekDays.length == 7;
  bool get _hasAtLeastOneDay => _selectedWeekDays.isNotEmpty;

  void _toggleAllDays(bool value) {
    setState(() {
      if (value) {
        _selectedWeekDays = _allWeekDays.toSet();
      } else {
        _selectedWeekDays.clear();
      }
    });
  }

  void _toggleWeekDay(int day) {
    setState(() {
      if (_selectedWeekDays.contains(day)) {
        _selectedWeekDays.remove(day);
      } else {
        _selectedWeekDays.add(day);
      }
    });
  }

  void _toggleUnavailableDate(DateTime day) {
    final d = _dateOnly(day);
    setState(() {
      if (_unavailableDates.contains(d)) {
        _unavailableDates.remove(d);
      } else {
        _unavailableDates.add(d);
      }
    });
  }

  void goToSummary() {
    if (!_hasAtLeastOneDay) return;

    widget.draft.availableWeekDays = _selectedWeekDays.toList()..sort();
    widget.draft.unavailableDates = _unavailableDates.toList()..sort();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateOfferSummaryScreen(draft: widget.draft),
      ),
    );
  }

  CalendarStyle get _calendarStyle {
    return CalendarStyle(
      // Cohérent avec ton style
      cellMargin: EdgeInsets.zero,
      cellPadding: EdgeInsets.zero,

      // Ici on n’est pas en range, mais on garde la config "propre"
      rangeHighlightColor: AppColors.primaryBlue.withOpacity(0.15),
      rangeHighlightScale: 1.0,
      withinRangeDecoration: const BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.rectangle,
      ),

      // On utilise la sélection pour marquer les indisponibilités
      selectedDecoration: const BoxDecoration(
        color: AppColors.primaryRed,
        shape: BoxShape.circle,
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
      selectedTextStyle: AppTextStyles.label.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      todayTextStyle: AppTextStyles.label.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
    );
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

  Widget _dayCheckbox({
    required String label,
    required bool checked,
    required VoidCallback onTap,
    bool isAllDays = false,
    bool indent = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.only(top: 6, bottom: 6, left: indent ? 10 : 0),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: Checkbox(
                value: checked,
                onChanged: (_) => onTap(),
                activeColor: AppColors.primaryBlue,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: (isAllDays ? AppTextStyles.caption : AppTextStyles.label)
                  .copyWith(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFFF4F4F4);

    return Scaffold(
      backgroundColor: bg,
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
          "Ajoutez vos disponibilités",
          style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              "3/3",
              style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 13, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Indiquez les périodes pendant lesquelles votre matériel\n"
              "est disponible afin de permettre aux locataires de\n"
              "réserver aux bonnes dates.",
              style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 24),

            Text("Votre matériel est disponible", style: AppTextStyles.h3),
            const SizedBox(height: 8),

            // Liste checkboxes
            Column(
              children: [
                _dayCheckbox(
                  label: "Tous les jours",
                  checked: _allDaysSelected,
                  onTap: () => _toggleAllDays(!_allDaysSelected),
                  isAllDays: true,
                ),
                const SizedBox(height: 4),
                _dayCheckbox(
                  label: "Lundi",
                  checked: _selectedWeekDays.contains(1),
                  onTap: () => _toggleWeekDay(1),
                  indent: true,
                ),
                _dayCheckbox(
                  label: "Mardi",
                  checked: _selectedWeekDays.contains(2),
                  onTap: () => _toggleWeekDay(2),
                  indent: true,
                ),
                _dayCheckbox(
                  label: "Mercredi",
                  checked: _selectedWeekDays.contains(3),
                  onTap: () => _toggleWeekDay(3),
                  indent: true,
                ),
                _dayCheckbox(
                  label: "Jeudi",
                  checked: _selectedWeekDays.contains(4),
                  onTap: () => _toggleWeekDay(4),
                  indent: true,
                ),
                _dayCheckbox(
                  label: "Vendredi",
                  checked: _selectedWeekDays.contains(5),
                  onTap: () => _toggleWeekDay(5),
                  indent: true,
                ),
                _dayCheckbox(
                  label: "Samedi",
                  checked: _selectedWeekDays.contains(6),
                  onTap: () => _toggleWeekDay(6),
                  indent: true,
                ),
                _dayCheckbox(
                  label: "Dimanche",
                  checked: _selectedWeekDays.contains(7),
                  onTap: () => _toggleWeekDay(7),
                  indent: true,
                ),
              ],
            ),

            const SizedBox(height: 24),

            Text("Votre matériel est indisponible", style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              "Indiquez les dates où votre matériel n'est pas accessible\n"
              "afin d'éviter toute réservation sur ces périodes.",
              style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TableCalendar(
                locale: 'fr_FR',
                firstDay: DateTime.now().subtract(const Duration(days: 0)),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.monday,
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle: AppTextStyles.caption.copyWith(
                    color: AppColors.textGrey800,
                  ),
                  weekendStyle: AppTextStyles.caption.copyWith(
                    color: AppColors.textGrey800,
                  ),
                ),
                headerStyle: _headerStyle,
                calendarStyle: _calendarStyle,

                selectedDayPredicate: (day) {
                  final isSel = _unavailableDates.contains(_dateOnly(day));
                  return isSel;
                },

                onDaySelected: (selectedDay, focusedDay) {
                  setState(() => _focusedDay = focusedDay);
                  _toggleUnavailableDate(selectedDay);
                },
                onPageChanged: (focusedDay) {
                  setState(() => _focusedDay = focusedDay);
                },
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
              text: "Suivant",
              onPressed: _hasAtLeastOneDay ? goToSummary : null,
            ),
          ),
        ),
      ),
    );
  }
}
