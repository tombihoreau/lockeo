import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/image.dart';
import '../theme/app_colors.dart';
import 'package:lockeo_app/theme/app_text_styles.dart';
import '../services/approx_loc_service.dart';
import 'selected_photo_image.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final ImageModel image;
  final VoidCallback? onTap;
  final VoidCallback? onToggleFavorite;

  const ProductCard({
    super.key,
    required this.product,
    required this.image,
    this.onTap,
    this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final canToggleFavorite = onToggleFavorite != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectedPhotoImage(
                  path: image.url,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      width: double.infinity,
                      color: const Color(0xFFE8EDF2),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.textGrey,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.h3.copyWith(color: Colors.black),
                      ),
                      const SizedBox(height: 10),
                      _distanceOrCity(),
                    ],
                  ),
                ),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${product.price?.toStringAsFixed(0)}€",
                        style: AppTextStyles.label.copyWith(
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "1 journée",
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (canToggleFavorite)
              Positioned(
                top: 10,
                right: 10,
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 2,
                  child: InkWell(
                    onTap: onToggleFavorite,
                    customBorder: const CircleBorder(),
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: Icon(
                        product.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 20,
                        color: product.isFavorite
                            ? const Color(0xFFE74C3C)
                            : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _distanceOrCity() {
    final approx = ApproxLocationService();

    return FutureBuilder<double?>(
      future: approx.distanceFromUser(product.city),
      builder: (context, snap) {
        String label;

        if (!snap.hasData || snap.data == null) {
          label = product.city;
        } else {
          final km = snap.data!;
          label = km < 10 ? "${km.toStringAsFixed(1)} km" : "${km.round()} km";
        }

        return Row(
          children: [
            Icon(Icons.place_outlined, size: 10, color: AppColors.textGrey),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.label.copyWith(color: AppColors.textGrey),
            ),
          ],
        );
      },
    );
  }
}
