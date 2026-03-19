import 'package:flutter/material.dart';
import 'package:lockeo_app/utils/app_navigator.dart';
import '../models/offer.dart';
import '../services/local_data_service.dart';
import '../models/product.dart';
import '../models/image.dart';
import '../widgets/button.dart';
import 'confirmation_reservation_screen.dart';
import 'package:lockeo_app/theme/app_text_styles.dart';
import '../theme/app_colors.dart';
import 'package:intl/intl.dart';
import '../widgets/security_card.dart';

class ReservationPaymentScreen extends StatefulWidget {
  final int offerId;
  final DateTime startDate;
  final DateTime endDate;

  const ReservationPaymentScreen({
    super.key,
    required this.offerId,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<ReservationPaymentScreen> createState() =>
      _ReservationPaymentScreenState();
}

class _ReservationPaymentScreenState extends State<ReservationPaymentScreen> {
  final dataService = LocalDataService();

  bool _isLoading = true;
  String? _loadError;

  Offer? _offer;
  Product? _product;
  ImageModel? _img;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final offer = await dataService.getOfferById(widget.offerId);
      if (offer == null) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _loadError = 'Offer introuvable (offerId=${widget.offerId}).';
        });
        return;
      }

      final products = await dataService.loadProducts();
      final images = await dataService.loadImages();

      final product = products.cast<Product?>().firstWhere(
        (p) => p?.productId == offer.productId,
        orElse: () => null,
      );

      if (product == null) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _loadError =
              'Produit introuvable pour offerId=${offer.offerId} (productId=${offer.productId}).';
        });
        return;
      }

      final productImage = images.cast<ImageModel?>().firstWhere(
        (img) => img?.productId == product.productId,
        orElse: () => null,
      );

      if (!mounted) return;
      setState(() {
        _offer = offer;
        _product = product;
        _img = productImage;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = 'Erreur de chargement: $e';
      });
    }
  }

  int get _days => widget.endDate.difference(widget.startDate).inDays + 1;

  double get _rentalPrice => (_product?.price ?? 0) * _days;

  double get _insurancePrice => _rentalPrice * 0.15;

  double get _total => _rentalPrice + _insurancePrice;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => AppNavigator.back(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _loadError!,
                style: AppTextStyles.body.copyWith(color: AppColors.primaryRed),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }
    if (_product == null) {
      return const Scaffold(
        body: Center(child: Text('Aucune donnée produit disponible.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Demande de location",
          style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => AppNavigator.back(context),
        ),
      ),

      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🧱 Carte produit
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        _img?.url ?? 'assets/images/default.jpg',
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _product!.name,
                            style: AppTextStyles.h2.copyWith(
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.black,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  "${_product?.city}, ${_product?.postalCode}",
                                  style: AppTextStyles.label.copyWith(
                                    color: Colors.black,
                                  ),
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
                                color: AppColors.textPrimary,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${(_product?.price ?? 0).round()}€ / jour",
                                style: AppTextStyles.label.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              //  Dates de location
              Text(
                "Durée de location",
                style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
              ),

              Row(
                children: [
                  const Icon(
                    Icons.calendar_month,
                    color: AppColors.textPrimary,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Du ${_formatDate(widget.startDate)} au ${_formatDate(widget.endDate)}",
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              SecurityCard(
                onTap: () {
                  // navigation ou ouverture modal
                },
              ),

              const SizedBox(height: 32),

              // 💳 Détail du paiement
              Text(
                "Détail du paiement",
                style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
              ),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Location ($_days jours)",
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text(
                      "${_rentalPrice.toStringAsFixed(2)}€",
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Comission Lockeo",
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textGrey800,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text(
                      "${_insurancePrice.toStringAsFixed(2)}€",
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textGrey800,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "${_total.toStringAsFixed(2)}€",
                      style: AppTextStyles.hero.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 💰 Moyens de paiement
              Text(
                "Moyen de paiement",
                style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _paymentTile('assets/images/LogoPaiement.png'),
                  _paymentTile('assets/images/LogoPaiement-1.png'),
                  _paymentTile('assets/images/LogoPaiement-2.png'),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),

      // 🟢 Bouton final
      bottomNavigationBar: Container(
        color: Colors.white,
        alignment: Alignment.center,
        height: 100,
        child: SizedBox(
          width: 300,
          child: CustomButton(
            text: "Demande de location",
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ReservationConfirmationScreen(
                    offerId: widget.offerId,
                    startDate: widget.startDate,
                    endDate: widget.endDate,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _paymentTile(String assetPath) {
    return Expanded(
      child: Container(
        height: 56,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Image.asset(
          assetPath,
          width: 70,
          height: 43,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    final formatted = DateFormat('d MMMM y', 'fr_FR').format(d);
    return formatted[0].toUpperCase() + formatted.substring(1);
  }
}
