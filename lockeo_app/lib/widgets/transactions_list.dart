import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lockeo_app/models/reservation.dart';
import 'package:lockeo_app/models/product.dart';
import 'package:lockeo_app/models/image.dart';
import 'package:lockeo_app/theme/app_colors.dart';
import 'package:lockeo_app/theme/app_text_styles.dart';

class TransactionsList extends StatelessWidget {
  final List<Reservation> reservations;
  final List<Product> products;
  final List<ImageModel> images;

  final int currentUserId;

  // callbacks
  final void Function(Reservation r)? onTapContact;
  final void Function(Reservation r)? onTapReview;

  const TransactionsList({
    super.key,
    required this.reservations,
    required this.products,
    required this.images,
    required this.currentUserId,
    this.onTapContact,
    this.onTapReview,
  });

  @override
  Widget build(BuildContext context) {
    if (reservations.isEmpty) {
      return const Center(child: Text("Aucune transaction pour le moment"));
    }

    final enCours = reservations.where((r) => _category(r.status) == _TxCat.enCours).toList();
    final prochain = reservations.where((r) => _category(r.status) == _TxCat.prochain).toList();
    final termine = reservations.where((r) => _category(r.status) == _TxCat.termine).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          if (enCours.isNotEmpty) _Section(children: enCours.map((r) => _Card(r)).toList()),
          if (prochain.isNotEmpty) _Section(children: prochain.map((r) => _Card(r)).toList()),
          if (termine.isNotEmpty) _Section(children: termine.map((r) => _Card(r)).toList()),
        ],
      ),
    );
  }

  Widget _Card(Reservation r) {
    final product = products.where((p) => p.productId == r.productId).cast<Product?>().firstWhere(
          (x) => x != null,
          orElse: () => null,
        );

    final img = images.where((i) => i.productId == r.productId).cast<ImageModel?>().firstWhere(
          (x) => x != null,
          orElse: () => null,
        );

    final productTitle = product?.name ?? "Produit";
    final imagePath = img?.url ?? "assets/images/default.jpg";

    final dateFormat = DateFormat('dd/MM/yyyy');
    final cat = _category(r.status);

    final ctaLabel = (cat == _TxCat.termine) ? "Ajouter un avis" : "Contacter le propriétaire";

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _chip(cat),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF0FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFCAD8FF)),
              ),
              child: _headlineWidget(cat, r.startDate, r.endDate, dateFormat),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    imagePath,
                    width: 145,
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
                        productTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Location du ${dateFormat.format(r.startDate)} au ${dateFormat.format(r.endDate)}",
                        style: AppTextStyles.label.copyWith(color: AppColors.textGrey800),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              if (cat == _TxCat.termine) {
                                onTapReview?.call(r);
                              } else {
                                onTapContact?.call(r);
                              }
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  ctaLabel,
                                  style: AppTextStyles.label.copyWith(color: AppColors.primaryBlue),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.chevron_right, size: 14, color: AppColors.primaryBlue),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(_TxCat cat) {
    String label;
    Color bg;
    Color fg;

    if (cat == _TxCat.termine) {
      label = "Terminé";
      bg = const Color(0xFFE9F9EE);
      fg = const Color(0xFF1F8A3B);
    } else if (cat == _TxCat.prochain) {
      label = "Prochain";
      bg = const Color(0xFFFFF1E6);
      fg = const Color(0xFFCC6A11);
    } else {
      label = "En cours";
      bg = const Color(0xFFFFF1E6);
      fg = const Color(0xFFCC6A11);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: fg),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.label.copyWith(color: fg)),
        ],
      ),
    );
  }

  Widget _headlineWidget(_TxCat cat, DateTime start, DateTime end, DateFormat fmt) {
    late final String title;
    late final String subtitle;

    if (cat == _TxCat.prochain) {
      title = "À récupérer le ${fmt.format(start)}";
      subtitle = "Contactez le propriétaire afin de prendre rendez-vous pour l'échange.";
    } else if (cat == _TxCat.enCours) {
      title = "À rendre le ${fmt.format(end)}";
      subtitle = "Contactez le propriétaire afin de prendre rendez-vous pour l'échange.";
    } else {
      title = "Transaction terminée";
      subtitle = "Vous pouvez contacter le propriétaire ou laisser un avis.";
    }

    // espace 8px entre les 2 lignes (le plus fiable sans prise de tête)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        Text(subtitle, style: AppTextStyles.label.copyWith(color: AppColors.textGrey800)),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final List<Widget> children;
  const _Section({required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(children: [const SizedBox(height: 10), ...children]);
  }
}

enum _TxCat { enCours, prochain, termine }

_TxCat _category(String status) {
  if (status == 'none' || status == 'checkout_validated' || status == 'completed') {
    return _TxCat.termine;
  }
  if (status == 'in_progress' || status == 'return_soon') {
    return _TxCat.prochain;
  }
  return _TxCat.enCours;
}
