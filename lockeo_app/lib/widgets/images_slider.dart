import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../models/image.dart';
import 'selected_photo_image.dart';

class ImageSlider extends StatefulWidget {
  final List<ImageModel> images;
  final double height;
  final double borderRadius;

  /// Optionnel : gestion du favori
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;

  const ImageSlider({
    super.key,
    required this.images,
    this.height = 250,
    this.borderRadius = 16,
    this.isFavorite = false,
    this.onToggleFavorite,
  });

  @override
  State<ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final displayedImages = widget.images.isNotEmpty
        ? widget.images
        : [
            ImageModel(
              imageId: 0,
              productId: 0,
              url: "assets/images/default.jpg",
              positionImage: 0,
              createdAt: "",
            ),
          ];

    return Stack(
      children: [
        // Carte avec coins arrondis + ombre légère
        CarouselSlider.builder(
          itemCount: displayedImages.length,
          options: CarouselOptions(
            height: widget.height,
            viewportFraction: 1.0,
            enableInfiniteScroll: false,
            enlargeCenterPage: false,
            onPageChanged: (index, _) {
              setState(() => _currentIndex = index);
            },
          ),
          itemBuilder: (context, index, realIdx) {
            final img = displayedImages[index];
            return SelectedPhotoImage(
              path: img.url,
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFFE8EDF2),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.grey,
                  ),
                );
              },
            );
          },
        ),

        // Bouton favori (en haut à droite)
        Positioned(
          top: 50,
          right: 12,
          child: GestureDetector(
            onTap: widget.onToggleFavorite,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
                ],
              ),
              child: Icon(
                widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                size: 20,
                color: widget.isFavorite
                    ? const Color(0xFFE74C3C)
                    : Colors.black87,
              ),
            ),
          ),
        ),

        if (displayedImages.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(displayedImages.length, (i) {
                  final active = i == _currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(right: 6),
                    width: active ? 20 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  );
                }),
              ),
            ),
          ),
      ],
    );
  }
}
