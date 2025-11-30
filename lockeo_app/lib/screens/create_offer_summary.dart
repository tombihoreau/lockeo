import 'dart:io';
import 'package:flutter/material.dart';
import '../models/offerDraft.dart';
import '../widgets/button.dart';
import '../services/local_data_service.dart';
import '../models/category.dart';
import '../widgets/category_card.dart';
import 'create_offer_end_screen.dart';

class CreateOfferSummary extends StatefulWidget {
  final OfferDraft draft;

  const CreateOfferSummary({super.key, required this.draft});

  @override
  State<CreateOfferSummary> createState() => _CreateOfferSummaryState();
}

class _CreateOfferSummaryState extends State<CreateOfferSummary> {
  List<Category> _allCategories = [];

  @override
  void initState() {
    super.initState();
    loadCats();
  }

  void loadCats() async {
    _allCategories = await LocalDataService().loadCategories();
    setState(() {});
  }
  void _saveAndContinue() {
    //save new offer
    //offerCount : prendre depuis la bdd le nombre d'annonces pour cet utilisateur +1
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateOfferEndScreen(
          offerTitle: widget.draft.title ?? '',
          offerDescription: widget.draft.description ?? '',
          offerImagePath:
              widget.draft.photos.isNotEmpty ? widget.draft.photos[0] : '',
          offerCount: 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.draft;
    List<Category> selectedCategories = _allCategories
        .where((cat) => d.categories.contains(cat.categoryId))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon annonce"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Informations générales",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 20),

            _buildLine("Titre", d.title),
            _buildLine("Description", d.description),
            _buildLine("État", d.state),
            _buildLine("Localisation", d.location),

            const SizedBox(height: 25),
            const Text(
              "Catégories",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            if (_allCategories.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: selectedCategories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: CategoryCard(
                        name: category.label,
                        iconName: category.iconName,
                      ),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 25),
            const Text(
              "Photos",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),

            _buildPhotosGrid(d.photos),

            const SizedBox(height: 25),
            const Text(
              "Prix",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 15),

            _buildLine(
              "Le prix pour une journée",
              d.pricePerDay != null ? "${d.pricePerDay}€" : null,
            ),

            _buildLine(
              "Le prix pour une semaine (7 jours)",
              d.pricePerWeek != null ? "${d.pricePerWeek}€" : null,
            ),

            const SizedBox(height: 25),
            const Text(
              "Les disponibilités",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),

            _buildLine(
              "À partir de",
              d.startDate != null
                  ? "${d.startDate!.day}/${d.startDate!.month}/${d.startDate!.year}"
                  : null,
            ),

            const SizedBox(height: 80),
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
            text: "Publier mon annonce",
            onPressed: _saveAndContinue,
          ),
        ),
      ),
    );
  }

  // Affichage d'une ligne label -> valeur
  Widget _buildLine(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color.fromRGBO(157, 160, 162, 1),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value ?? "Non renseigné",
            style: const TextStyle(color: Colors.black87, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Grid de photos (paths)
  Widget _buildPhotosGrid(List<String> photos) {
    if (photos.isEmpty) {
      return const Text("Aucune photo");
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: photos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (ctx, i) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(File(photos[i]), fit: BoxFit.cover),
        );
      },
    );
  }
}
