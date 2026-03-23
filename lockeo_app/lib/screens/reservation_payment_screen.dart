import 'package:flutter/material.dart';
import 'package:lockeo_app/utils/app_navigator.dart';
import '../models/product_detail.dart';
import '../models/product.dart';
import '../models/image.dart';
import '../services/products_service.dart';
import '../widgets/button.dart';
import '../widgets/selected_photo_image.dart';
import 'confirmation_reservation_screen.dart';
import 'package:lockeo_app/theme/app_text_styles.dart';
import '../theme/app_colors.dart';
import 'package:intl/intl.dart';
import '../utils/rental_pricing.dart';
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
  final _productsService = ProductsService();

  bool _isLoading = true;
  String? _loadError;

  ProductDetail? _detail;
  Product? _product;
  ImageModel? _img;
  bool _submitting = false;

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
      final detail = await _productsService.getOfferDetail(widget.offerId);
      final product = detail.product;
      final productImage = detail.images.isNotEmpty
          ? detail.images.first
          : ImageModel(
              imageId: 0,
              productId: product.productId,
              url: 'assets/images/default.jpg',
              positionImage: 0,
              createdAt: '',
            );

      if (!mounted) return;
      setState(() {
        _detail = detail;
        _product = product;
        _img = productImage;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = "Impossible de charger les informations de la location.";
        _isLoading = false;
      });
    }
  }

  int get _days => widget.endDate.difference(widget.startDate).inDays + 1;

  RentalPriceBreakdown get _pricing =>
      RentalPricing.breakdownForProduct(_product!, _days);

  double get _rentalPrice => _pricing.rentalPrice;

  double get _insurancePrice => _rentalPrice * 0.15;

  double get _total => _rentalPrice + _insurancePrice;

  Future<void> _submitReservation() async {
    if (_detail == null || _submitting) return;

    setState(() => _submitting = true);
    try {
      final createdReservation = await _productsService.createReservation(
        offerId: widget.offerId,
        startDate: widget.startDate,
        endDate: widget.endDate,
      );
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ReservationConfirmationScreen(
            offerId: widget.offerId,
            startDate: widget.startDate,
            endDate: widget.endDate,
            initialDetail: _detail,
            conversationId: createdReservation.conversationId,
            reservationId: createdReservation.reservationId,
            reservationTotalPrice: _rentalPrice,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_formatReservationError(e))));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  String _formatReservationError(Object error) {
    final raw = error.toString();
    const bodyMarker = 'body=';
    final bodyIndex = raw.indexOf(bodyMarker);
    if (bodyIndex >= 0) {
      final body = raw.substring(bodyIndex + bodyMarker.length).trim();
      final messageMatch = RegExp(r'"message":"([^"]+)"').firstMatch(body);
      if (messageMatch != null) {
        return messageMatch.group(1)!;
      }
    }
    return "Impossible d'envoyer la demande de location.";
  }

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
                      child: SelectedPhotoImage(
                        path: _img?.url ?? 'assets/images/default.jpg',
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
                                "${_pricing.dailyRate.toStringAsFixed(2)}€ / jour",
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
                      "Location ($_days jours a ${_pricing.dailyRate.toStringAsFixed(2)}€/jour)",
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
            text: _submitting ? "Envoi..." : "Demande de location",
            onPressed: _submitting ? null : _submitReservation,
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
