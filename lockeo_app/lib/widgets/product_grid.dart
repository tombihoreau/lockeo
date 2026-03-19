import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/image.dart';
import '../models/offer.dart';
import '../models/product.dart';
import '../models/reservation.dart';
import '../services/location_service.dart';
import '../services/local_data_service.dart';
import '../widgets/product_card.dart';

class ProductGrid extends StatefulWidget {
  final List<Offer>? offers;
  final int? maxItems;
  final bool shrinkWrap;
  final bool randomize;
  final bool favoritesOnly;
  final String? searchQuery;
  final List<int>? selectedCategories;
  final double? maxDistance;
  final RangeValues? priceRange;
  final String? sortBy;
  final ValueChanged<int>? onCountChanged;

  const ProductGrid({
    super.key,
    this.offers,
    this.maxItems,
    this.shrinkWrap = false,
    this.randomize = false,
    this.favoritesOnly = false,
    this.searchQuery,
    this.selectedCategories,
    this.maxDistance,
    this.priceRange,
    this.sortBy,
    this.onCountChanged,
  });

  @override
  State<ProductGrid> createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  final LocalDataService _dataService = LocalDataService();
  List<int> _randomizedOfferIds = [];

  Future<void> _toggleFavorite(int productId) async {
    await _dataService.toggleFavoriteProduct(productId);
    if (!mounted) return;
    setState(() {});
  }

  void _syncRandomOrder(List<Offer> offers) {
    final currentIds = offers.map((offer) => offer.offerId).toSet();

    _randomizedOfferIds = _randomizedOfferIds
        .where(currentIds.contains)
        .toList();

    final missingIds = offers
        .map((offer) => offer.offerId)
        .where((id) => !_randomizedOfferIds.contains(id))
        .toList()
      ..shuffle();

    _randomizedOfferIds.addAll(missingIds);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        _dataService.loadProducts(),
        _dataService.loadImages(),
        _dataService.loadOffers(),
        _dataService.loadReservations(),
        LocationService().getStoredLatLng(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text("Erreur ou données introuvables"));
        }

        var products = snapshot.data![0] as List<Product>;
        final images = snapshot.data![1] as List<ImageModel>;
        final allOffers = snapshot.data![2] as List<Offer>;
        final reservations = snapshot.data![3] as List<Reservation>;
        final userLatLng = snapshot.data![4] as ({double lat, double lng})?;

        if (widget.favoritesOnly) {
          products = products.where((p) => p.isFavorite).toList();
        }

        if (widget.selectedCategories != null &&
            widget.selectedCategories!.isNotEmpty) {
          products = products.where((p) {
            final productCategories = p.categoryIds;
            return productCategories.any(
              (id) => widget.selectedCategories!.contains(id),
            );
          }).toList();
        }

        if (widget.priceRange != null) {
          final minPrice = widget.priceRange!.start;
          final maxPrice = widget.priceRange!.end;

          products = products.where((p) {
            final price = p.price ?? 0.0;
            return price >= minPrice && price <= maxPrice;
          }).toList();
        }

        double? distanceFor(Product product) {
          if (userLatLng == null ||
              product.latitude == null ||
              product.longitude == null) {
            return null;
          }

          final meters = Geolocator.distanceBetween(
            userLatLng.lat,
            userLatLng.lng,
            product.latitude!,
            product.longitude!,
          );
          return meters / 1000.0;
        }

        if (widget.maxDistance != null) {
          products = products.where((p) {
            final distance = distanceFor(p);
            if (distance == null) return true;
            return distance <= widget.maxDistance!;
          }).toList();
        }

        if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
          final query = widget.searchQuery!.toLowerCase();
          products = products
              .where((p) => p.name.toLowerCase().contains(query))
              .toList();
          if (products.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.onCountChanged?.call(0);
            });
            return const Center(
              child: Text("Aucun produit ne correspond à la recherche"),
            );
          }
        }

        final visibleOffers = widget.offers ?? allOffers;

        var validOffers = visibleOffers
            .where(
              (o) => products.any(
                (p) => p.productId == o.productId && p.isAvailable,
              ),
            )
            .toList();

        if (widget.randomize) {
          _syncRandomOrder(validOffers);
          validOffers.sort(
            (a, b) => _randomizedOfferIds.indexOf(a.offerId).compareTo(
              _randomizedOfferIds.indexOf(b.offerId),
            ),
          );
        }

        switch (widget.sortBy) {
          case "Distance":
            validOffers.sort((a, b) {
              final productA = products.firstWhere(
                (p) => p.productId == a.productId,
                orElse: () => products.first,
              );
              final productB = products.firstWhere(
                (p) => p.productId == b.productId,
                orElse: () => products.first,
              );

              final distanceA = distanceFor(productA) ?? double.infinity;
              final distanceB = distanceFor(productB) ?? double.infinity;

              return distanceA.compareTo(distanceB);
            });
            break;

          case "Popularité":
            validOffers.sort((a, b) {
              final popularityA = reservations
                  .where((r) => r.productId == a.productId)
                  .length;
              final popularityB = reservations
                  .where((r) => r.productId == b.productId)
                  .length;

              if (popularityA != popularityB) {
                return popularityB.compareTo(popularityA);
              }

              final productA = products.firstWhere(
                (p) => p.productId == a.productId,
                orElse: () => products.first,
              );
              final productB = products.firstWhere(
                (p) => p.productId == b.productId,
                orElse: () => products.first,
              );

              final distanceA = distanceFor(productA) ?? double.infinity;
              final distanceB = distanceFor(productB) ?? double.infinity;

              return distanceA.compareTo(distanceB);
            });
            break;

          case "Prix":
            validOffers.sort((a, b) {
              final productA = products.firstWhere(
                (p) => p.productId == a.productId,
                orElse: () => products.first,
              );
              final productB = products.firstWhere(
                (p) => p.productId == b.productId,
                orElse: () => products.first,
              );

              final priceA = productA.price ?? 0.0;
              final priceB = productB.price ?? 0.0;

              return priceA.compareTo(priceB);
            });
            break;
          case "Nouveautés":
            validOffers.sort((a, b) {
              final productA = products.firstWhere(
                (p) => p.productId == a.productId,
                orElse: () => products.first,
              );
              final productB = products.firstWhere(
                (p) => p.productId == b.productId,
                orElse: () => products.first,
              );
              return DateTime.parse(
                productB.createdAt,
              ).compareTo(DateTime.parse(productA.createdAt));
            });
            break;
        }

        final displayedOffers = widget.maxItems != null
            ? validOffers.take(widget.maxItems!).toList()
            : validOffers;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onCountChanged?.call(displayedOffers.length);
        });

        if (displayedOffers.isEmpty) {
          return const Center(child: Text("Aucun produit disponible"));
        }

        return GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: widget.shrinkWrap,
          physics: widget.shrinkWrap
              ? const NeverScrollableScrollPhysics()
              : const ScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 0.62,
          ),
          itemCount: displayedOffers.length,
          itemBuilder: (context, index) {
            final offer = displayedOffers[index];
            final product = products.firstWhere(
              (p) => p.productId == offer.productId,
            );

            final productImages = images
                .where((img) => img.productId == product.productId)
                .toList();

            final firstImage = productImages.isNotEmpty
                ? productImages.first
                : ImageModel(
                    imageId: 0,
                    productId: product.productId,
                    url: "assets/images/default.jpg",
                    positionImage: 0,
                    createdAt: "",
                  );

            return ProductCard(
              product: product,
              image: firstImage,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/productDetails',
                  arguments: offer,
                );
              },
              onToggleFavorite: () => _toggleFavorite(product.productId),
            );
          },
        );
      },
    );
  }
}
