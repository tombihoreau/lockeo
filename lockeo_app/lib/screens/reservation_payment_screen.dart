import 'package:flutter/material.dart';
import '../models/offer.dart';
import '../services/local_data_service.dart';
import '../models/product.dart';
import '../widgets/button.dart';

class ReservationPaymentScreen extends StatefulWidget {
  final int offerId;
  final DateTime startDate;
  final DateTime endDate;

  ReservationPaymentScreen({
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

  Offer? _offer;
  Product? _product;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final offer = await dataService.getOfferById(widget.offerId);

    if (offer == null) return;
    final products = await dataService.loadProducts();
    final product = products.firstWhere((p) => p.productId == offer.productId);

    setState(() {
      _offer = offer;
      _product = product;
    });
  }

  int get _days => widget.endDate.difference(widget.startDate).inDays + 1;

  double get _rentalPrice => (_product?.price ?? 0) * _days;

  double get _insurancePrice => _rentalPrice * 0.06;

  double get _total => _rentalPrice + _insurancePrice;

  @override
  Widget build(BuildContext context) {
    if (_product == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Réserver votre location",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🧱 Carte produit
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        "assets/images/default.jpg",
                        width: 80,
                        height: 80,
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
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${(_product?.price ?? 0).round()}€ / jour",
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 📅 Dates de location
              const Text(
                "Jour de location",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                "${_formatDate(widget.startDate)} → ${_formatDate(widget.endDate)} ($_days jours)",
                style: const TextStyle(color: Colors.black87),
              ),

              const SizedBox(height: 24),

              // 🛡️ Assurance
              const Text(
                "Assurance",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),

              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Protection contre les dommages pendant la location.",
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 💳 Détail du paiement
              const Text(
                "Détail du paiement",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 12),
              _priceRow("Location ($_days jours)", _rentalPrice),
              _priceRow(
                "Assurance",
                _insurancePrice,
                color: Color.fromRGBO(212, 133, 13, 1),
              ),

              const Divider(height: 32),
              _priceRow("Total", _total, isBold: true),

              const SizedBox(height: 24),

              // 💰 Moyens de paiement
              const Text(
                "Moyen de paiement",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _paymentTile("Carte"),
                  _paymentTile("Apple Pay"),
                  _paymentTile("PayPal"),
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
          child: CustomButton(text: "Demande de location", onPressed: () {}),
        ),
      ),
    );
  }

  Widget _priceRow(
    String label,
    double price, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
              color: color,
            ),
          ),
          Text(
            "${price.toStringAsFixed(2)}€",
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentTile(String label) {
    return Expanded(
      child: Container(
        height: 56,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(label),
      ),
    );
  }

  String _formatDate(DateTime d) => "${d.day}/${d.month}/${d.year}";
}
