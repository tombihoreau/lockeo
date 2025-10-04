import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../models/image.dart';

class ImageSlider extends StatefulWidget {
  final List<ImageModel> images;
  final double height;
  final double borderRadius;

  const ImageSlider({
    super.key,
    required this.images,
    this.height = 250,
    this.borderRadius = 16,
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
            )
          ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CarouselSlider.builder(
          itemCount: displayedImages.length,
          options: CarouselOptions(
            height: widget.height,
            viewportFraction: 1.0,
            enableInfiniteScroll: false,
            enlargeCenterPage: false, 
            onPageChanged: (index, _) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          itemBuilder: (context, index, realIdx) {
            final img = displayedImages[index];
            return ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: Image.asset(
                img.url,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            );
          },
        ),

        const SizedBox(height: 8),

        if (displayedImages.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(displayedImages.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _currentIndex == index ? 10 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == index
                      ? Colors.black
                      : Colors.grey.withOpacity(0.3),
                ),
              );
            }),
          ),
      ],
    );
  }
}
