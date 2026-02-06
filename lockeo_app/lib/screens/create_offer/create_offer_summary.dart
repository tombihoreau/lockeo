import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/offerDraft.dart';
import '../../widgets/button.dart';
import '../../services/local_data_service.dart';
import '../../models/category.dart';
import '../../widgets/category_card.dart';
import 'create_offer_end_screen.dart';
import 'package:lockeo_app/theme/app_colors.dart';
import 'package:lockeo_app/theme/app_text_styles.dart';

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
          offerImagePath: widget.draft.photos.isNotEmpty
              ? widget.draft.photos[0]
              : '',
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
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pushNamed(context, '/'),
        ),
        title: const Text("Mon annonce", style: AppTextStyles.h2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Vos photos",
              style: AppTextStyles.h3.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),

            _buildPhotosGrid(d.photos),

            const SizedBox(height: 24),

            Text(
              d.title ?? "Titre de l'annonce",
              style: AppTextStyles.h1.copyWith(color: Colors.black),
            ),
            const SizedBox(height: 13),

            // Localisation
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.black, size: 18),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    "${d.location}",
                    style: AppTextStyles.label.copyWith(color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.savings_outlined,
                  color: Colors.black,
                  size: 18,
                ),
                const SizedBox(width: 6),

                Text(
                  "${d.pricePerDay?.toStringAsFixed(0)}€/jour",
                  style: AppTextStyles.label.copyWith(color: Colors.black),
                ),

                const SizedBox(width: 10),

                // if (d.price3Days != null)
                //   _PriceChip(
                //     text:
                //         "${product.price3Days!.toStringAsFixed(0)}€ pour 3 jours",
                //   ),
                const SizedBox(width: 8),

                if (d.pricePerWeek != null)
                  _PriceChip(
                    text: "${d.pricePerWeek!.toStringAsFixed(0)}€ pour 7 jours",
                  ),
              ],
            ),

            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.bookmark_border,
                  color: Colors.black,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    d.state ?? "État inconnu",
                    style: AppTextStyles.label.copyWith(color: Colors.black),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Description
            const Text("Description", style: AppTextStyles.label),
            const SizedBox(height: 12),
            Text(
              d.description ?? "Aucune description",
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            const Text("Catégories", style: AppTextStyles.label),

            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: selectedCategories.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CategoryCard(name: category.label),
                  );
                }).toList(),
              ),
            ),
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
