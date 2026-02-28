import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class AvailabilityCalendarCard extends StatefulWidget {
  final bool Function(DateTime day) isUnavailableDay;

  const AvailabilityCalendarCard({
    super.key,
    required this.isUnavailableDay,
  });

  @override
  State<AvailabilityCalendarCard> createState() => _AvailabilityCalendarCardState();
}

class _AvailabilityCalendarCardState extends State<AvailabilityCalendarCard> {
  DateTime _focusedDay = DateTime.now();
  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isPastDate(DateTime day) {
    final today = _dateOnly(DateTime.now());
    return _dateOnly(day).isBefore(today);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar(
        locale: 'fr_FR',
        firstDay: DateTime.now().subtract(const Duration(days: 60)),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: _focusedDay,

        // ✅ changement de mois = rebuild uniquement de ce widget
        onPageChanged: (day) => setState(() => _focusedDay = day),

        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),

        // ✅ jours indispos grisés
        enabledDayPredicate: (day) =>
            !_isPastDate(day) && !widget.isUnavailableDay(day),

        // calendrier informatif (pas de sélection)
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          disabledTextStyle: TextStyle(color: Colors.grey.shade600),
          defaultTextStyle: const TextStyle(color: Colors.black),
          weekendTextStyle: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
