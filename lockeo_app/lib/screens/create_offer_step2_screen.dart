import 'package:flutter/material.dart';
import '../models/offerDraft.dart';
import '../widgets/button.dart';
import 'create_offer_summary.dart';


class CreateOfferStep2Screen extends StatefulWidget {
  final OfferDraft draft;

  const CreateOfferStep2Screen({super.key, required this.draft});

  @override
  State<CreateOfferStep2Screen> createState() => _CreateOfferStep2ScreenState();
}

class _CreateOfferStep2ScreenState extends State<CreateOfferStep2Screen> {
  final pricePerDayController = TextEditingController();
  final pricePerWeekController = TextEditingController();

  DateTime? selectedStartDate;

  @override
  void initState() {
    super.initState();
  }

  Future<void> pickStartDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedStartDate ?? now,
      firstDate: now,
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() => selectedStartDate = picked);
    }
  }

  void goToSummary() {
    if (pricePerDayController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez entrer un prix par jour."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedStartDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez choisir une date de disponibilité."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final draft = OfferDraft(
      pricePerDay: double.tryParse(pricePerDayController.text.trim()),
      pricePerWeek: double.tryParse(pricePerWeekController.text.trim()),
      startDate: selectedStartDate
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateOfferSummary(draft: draft),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
            const BorderSide(color: Color(0xFF00434A), width: 1.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Ajouter mon annonce",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Text(
              "2/2",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Prix",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),
            const Text("Le prix pour une journée"),
            const SizedBox(height: 8),

            TextField(
              controller: pricePerDayController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration("ex : 15€"),
            ),

            const SizedBox(height: 20),
            const Text("Le prix pour une semaine (7 jours)"),
            const SizedBox(height: 8),

            TextField(
              controller: pricePerWeekController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration("ex : 80€"),
            ),

            const SizedBox(height: 30),
            const Text(
              "Les disponibilités",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),
            const Text("À partir de"),
            const SizedBox(height: 8),

            GestureDetector(
              onTap: pickStartDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedStartDate == null
                          ? "Choisir une date"
                          : "${selectedStartDate!.day}/${selectedStartDate!.month}/${selectedStartDate!.year}",
                      style: const TextStyle(fontSize: 15),
                    ),
                    const Icon(Icons.expand_more),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 120),
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
            text: "Suivant",
            onPressed: goToSummary,
          ),
        ),
      ),
    );
  }

  
}
