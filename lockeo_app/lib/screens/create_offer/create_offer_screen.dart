import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:lockeo_app/utils/app_navigator.dart';
import '../../widgets/button.dart';
import '../../models/category.dart';
import '../../models/offerDraft.dart';
import '../../services/category_service.dart';
import '../../services/local_data_service.dart';
import '../../services/location_service.dart';
import 'package:lockeo_app/theme/app_colors.dart';
import 'package:lockeo_app/theme/app_text_styles.dart';
import '../../widgets/offer_categories_selector.dart';
import '../../widgets/selected_photo_image.dart';
import 'create_offer_step2_screen.dart';
import '../../widgets/main_scaffold.dart';
import '../home_screen.dart';

class CreateOfferScreen extends StatefulWidget {
  const CreateOfferScreen({super.key});

  @override
  State<CreateOfferScreen> createState() => _CreateOfferScreenState();
}

class _CreateOfferScreenState extends State<CreateOfferScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  String? selectedState;

  String? location;
  final TextEditingController _locationCtrl = TextEditingController();

  final _loc = LocationService();

  final dataService = LocalDataService();
  final _categoryService = CategoryService();

  List<Category> _categories = [];
  List<int> _selectedCategories = [];

  List<XFile> photos = [];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _locationCtrl.text = location ?? "";
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryService.fetchCategories();
      if (categories.isNotEmpty) {
        setState(() => _categories = categories);
        return;
      }
    } catch (_) {
      // Fallback local en environnement sans backend.
    }

    final localCategories = await dataService.loadCategories();
    setState(() => _categories = localCategories);
  }

  Future<void> pickPhoto() async {
    if (photos.length >= 5) return;

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => photos.add(image));
    }
  }

  Future<void> _fillLocationFromGPS() async {
    final label = await _loc.getCachedOrCurrentLocationLabel();
    if (label == null || label.trim().isEmpty) return;

    setState(() {
      location = label;
      _locationCtrl.text = label;
    });
  }

  Future<void> _onManualLocationChanged(String value) async {
    final normalized = value.trim();
    setState(() {
      location = normalized.isEmpty ? null : normalized;
    });

    await _loc.clearStoredLatLng();
  }

  bool _hasSelectedParent() {
    final selected = _selectedCategories.toSet();
    return _categories.any(
      (category) => category.isParent && selected.contains(category.categoryId),
    );
  }

  void _goToStep2() {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez entrer un titre."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (photos.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez ajouter au moins trois photos."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_hasSelectedParent()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez choisir une catégorie parente."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final draft = OfferDraft(
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      state: selectedState,
      location: location,
      categories: List<int>.from(_selectedCategories),
      photos: photos,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateOfferStep2Screen(draft: draft)),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.label.copyWith(color: AppColors.cape400),
      filled: true,
      fillColor: Colors.white,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
    );
  }

  Widget buildPhotosPicker({
    required List<XFile> photos,
    required VoidCallback pickPhoto,
    required VoidCallback onChanged,
  }) {
    const double gap = 6;
    const double radius = 12;

    const double minHeight = 190;

    void removeAt(int index) {
      if (index >= photos.length) return;
      photos.removeAt(index);
      onChanged();
    }

    Widget tile({required int index, required bool isLarge}) {
      final bool hasPhoto = index < photos.length;

      return Container(
        decoration: BoxDecoration(
          color: hasPhoto ? Colors.white : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasPhoto)
              ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: SelectedPhotoImage(
                  path: photos[index].path,
                  fit: BoxFit.cover,
                ),
              )
            else
              Center(
                child: IconButton(
                  onPressed: photos.length >= 5 ? null : pickPhoto,
                  icon: Icon(
                    Icons.add_a_photo_outlined,
                    size: isLarge ? 34 : 26,
                    color: Colors.grey.shade600,
                  ),
                  splashRadius: isLarge ? 26 : 22,
                  tooltip: "Ajouter une photo",
                ),
              ),

            // Bouton poubelle (uniquement si photo)
            if (hasPhoto)
              Positioned(
                top: 8,
                right: 8,
                child: InkWell(
                  onTap: () => removeAt(index),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalW = constraints.maxWidth;

        final rightW = totalW * 0.40;
        final leftW = totalW - gap - rightW;
        final height = minHeight;
        final small = (height - gap) / 2;

        return SizedBox(
          height: height,
          child: Row(
            children: [
              SizedBox(
                width: leftW,
                height: height,
                child: tile(index: 0, isLarge: true),
              ),
              const SizedBox(width: gap),
              SizedBox(
                width: rightW,
                height: height,
                child: Column(
                  children: [
                    SizedBox(
                      height: small,
                      child: Row(
                        children: [
                          Expanded(child: tile(index: 1, isLarge: false)),
                          const SizedBox(width: gap),
                          Expanded(child: tile(index: 2, isLarge: false)),
                        ],
                      ),
                    ),
                    const SizedBox(height: gap),
                    SizedBox(
                      height: small,
                      child: Row(
                        children: [
                          Expanded(child: tile(index: 3, isLarge: false)),
                          const SizedBox(width: gap),
                          Expanded(child: tile(index: 4, isLarge: false)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: InkWell(
            onTap: () => AppNavigator.back(
              context,
              fallbackBuilder: (_) =>
                  const MainScaffold(currentIndex: 0, child: HomeScreen()),
            ),
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
          "Ajouter mon annonce",
          style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              "1/3",
              style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Photos", style: AppTextStyles.h3),
            const SizedBox(height: 12),
            Row(
              children: [
                Text("Ajouter des photos ", style: AppTextStyles.label),
                Text(
                  "(Minimum 3 images)",
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primaryRed,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            buildPhotosPicker(
              photos: photos,
              pickPhoto: pickPhoto,
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 24),

            const Text("Informations générales", style: AppTextStyles.h3),
            const SizedBox(height: 12),

            const Text("Titre", style: AppTextStyles.label),
            const SizedBox(height: 4),

            Container(
              clipBehavior: Clip.antiAlias, // IMPORTANT
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: TextField(
                controller: titleController,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textPrimary, // couleur du texte saisi
                ),
                decoration: _inputDecoration("Titre de l'annonce"),
              ),
            ),

            const SizedBox(height: 12),

            const Text("Description", style: AppTextStyles.label),
            const SizedBox(height: 4),

            Container(
              clipBehavior: Clip.antiAlias, // IMPORTANT
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: TextField(
                controller: descriptionController,
                maxLines: 4,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textPrimary,
                ),
                decoration: _inputDecoration(
                  "ex : utilisé quelques fois, état, marque...",
                ),
              ),
            ),

            const SizedBox(height: 12),

            const Text("État", style: AppTextStyles.label),
            const SizedBox(height: 4),
            Container(
              clipBehavior: Clip.antiAlias, // IMPORTANT
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  style: AppTextStyles.label.copyWith(
                    color:
                        AppColors.textPrimary, // couleur du texte sélectionné
                  ),
                  hint: const Text("État", style: AppTextStyles.label),
                  value: selectedState,
                  items: ["Neuf", "Très bon", "Bon", "Satisfaisant"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) => setState(() => selectedState = value),
                ),
              ),
            ),

            const SizedBox(height: 12),

            const Text("Localisation", style: AppTextStyles.label),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _locationCtrl,
                      keyboardType: TextInputType.text,
                      autofillHints: const [AutofillHints.addressCity],
                      onChanged: (value) {
                        _onManualLocationChanged(value);
                      },
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Saisissez votre ville",
                        hintStyle: AppTextStyles.label.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.my_location),
                    onPressed: _fillLocationFromGPS,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            const Text("Catégories", style: AppTextStyles.label),
            const SizedBox(height: 8),
            OfferCategoriesSelector(
              categories: _categories,
              selectedCategories: _selectedCategories,
              onChanged: (updatedList) {
                setState(() => _selectedCategories = updatedList);
              },
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
          child: CustomButton(text: "Suivant", onPressed: _goToStep2),
        ),
      ),
    );
  }
}
