import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:lockeo_app/screens/reservation_payment_screen.dart';

class ReservationSheet extends StatefulWidget {
  const ReservationSheet({super.key});

  @override
  State<ReservationSheet> createState() => _ReservationSheetState();
}

class _ReservationSheetState extends State<ReservationSheet> {
  DateTime? startDate;
  DateTime? endDate;
  DateTime focusedDay = DateTime.now();

  bool isPastDate(DateTime day) {
    final now = DateTime.now();
    return day.isBefore(DateTime(now.year, now.month, now.day));
  }

  bool isSelected(DateTime day) {
    if (startDate == null) return false;

    // sélection du start uniquement
    if (endDate == null) {
      return isSameDay(day, startDate);
    }

    // sélection du range
    return day.isAfter(startDate!.subtract(const Duration(days: 1))) &&
        day.isBefore(endDate!.add(const Duration(days: 1)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40),
                const Text(
                  "Réservation",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            // CALENDRIER
            TableCalendar(
              firstDay: DateTime.now(), // interdit dates passées
              lastDay: DateTime(2035),
              focusedDay: focusedDay,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              enabledDayPredicate: (day) =>
                  !isPastDate(day), // bloque dates passées
              selectedDayPredicate: isSelected, // sélection custom
              onDaySelected: (day, _) {
                setState(() {
                  // Si on n'a pas encore choisi la 1ère date
                  if (startDate == null ||
                      (startDate != null && endDate != null)) {
                    startDate = day;
                    endDate = null;
                  }
                  // Sinon, on choisit la 2ème date
                  else if (day.isAfter(startDate!)) {
                    endDate = day;
                  }
                  // Si l’utilisateur clique une date avant la startDate → on remplace
                  else {
                    startDate = day;
                    endDate = null;
                  }
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Color(0xFF00434A),
                  shape: BoxShape.circle,
                ),
                rangeHighlightColor: const Color(0x33405E6E),
                rangeStartDecoration: const BoxDecoration(
                  color: Color(0xFF00434A),
                  shape: BoxShape.circle,
                ),
                rangeEndDecoration: const BoxDecoration(
                  color: Color(0xFF00434A),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // TEXTE DU PRIX
            if (startDate != null && endDate != null)
              Text(
                "Votre coût initial sera de 10€", // logiques pricing ici
                style: const TextStyle(color: Colors.black54),
              )
            else
              const Text(
                "Sélectionnez une plage de dates",
                style: TextStyle(color: Colors.black54),
              ),

            const SizedBox(height: 20),

            // BOUTON
            // BOUTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (startDate != null && endDate != null)
                    ? () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const ReservationPaymentScreen(),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00434A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Louer maintenant",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
