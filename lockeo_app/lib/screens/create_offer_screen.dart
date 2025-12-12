import 'package:flutter/material.dart';
import '../widgets/button.dart';
import '../widgets/categories_selector.dart';
import '../models/category.dart';
import '../services/local_data_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/offerDraft.dart';
import 'create_offer_step2_screen.dart';

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

  final dataService = LocalDataService();

  List<Category> _categories = [];
  List<int> _selectedCategories = [];

  List<String> photos = [];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await dataService.loadCategories();
    setState(() => _categories = categories);
  }

  Future<void> pickPhoto() async {
    if (photos.length >= 5) return;

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => photos.add(image.path));
    }
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

    final draft = OfferDraft(
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      state: selectedState,
      location: location,
      categories: _selectedCategories,
      photos: photos,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateOfferStep2Screen(draft: draft),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Color(0xFF00434A), width: 1.8),
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
          onPressed: () => Navigator.pushNamed(context, '/'),
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
              "1/2",
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
              "Informations générales",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Titre
            const Text("Titre"),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: _inputDecoration("Titre de l'annonce"),
            ),

            const SizedBox(height: 20),

            // Description
            const Text("Description"),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: _inputDecoration(
                "ex : utilisé quelques fois, état, marque...",
              ),
            ),

            const SizedBox(height: 20),

            // État
            const Text("État"),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text("État"),
                  value: selectedState,
                  items: ["Neuf", "Très bon", "Bon", "Satisfaisant"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) => setState(() => selectedState = value),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Localisation
            const Text("Localisation"),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: location),
                      readOnly: true,
                      decoration: const InputDecoration(border: InputBorder.none),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.my_location),
                    onPressed: () {
                      // Position GPS plus tard
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Catégories
            const Text("Catégories"),
            const SizedBox(height: 12),
            CategoriesSelector(
              categories: _categories,
              selectedCategories: _selectedCategories,
              onChanged: (updatedList) {
                setState(() => _selectedCategories = updatedList);
              },
            ),

            const SizedBox(height: 25),

            // Photos
            const Text("Photos", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            const Row(
              children: [
                Text("Ajouter vos photos ", style: TextStyle(color: Colors.black54)),
                Text("(Max 5)", style: TextStyle(color: Colors.orange)),
              ],
            ),
            const SizedBox(height: 12),

            // Grille photos
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisExtent: 110,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (_, index) {
                final hasPhoto = index < photos.length;

                return GestureDetector(
                  onLongPress: hasPhoto
                      ? () => setState(() => photos.removeAt(index))
                      : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: hasPhoto
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(photos[index]),
                              fit: BoxFit.cover,
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.add_a_photo),
                            onPressed: pickPhoto,
                          ),
                  ),
                );
              },
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
            onPressed: _goToStep2,
          ),
        ),
      ),
    );
  }
}
