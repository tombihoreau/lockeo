import 'package:flutter/material.dart';
import '../widgets/button.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum ConversationRole { renter, owner }

enum ReservationStatus {
  none,
  requestPending,
  accepted,
  exchangePending,
  completed,
}

class ConversationHeader extends StatelessWidget {
  final ConversationRole role;
  final ReservationStatus status;

  final String productTitle;
  final String priceLabel;
  final String dateLabel;
  final String ownerName;
  final String imagePath;

  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onMakeOffer;
  final VoidCallback? onOpenInventory;
  final VoidCallback? onValidateInventory;

  final String cityLabel;
  final String postalCodeLabel;
  final double pricePerDay;

  const ConversationHeader({
    super.key,
    required this.role,
    required this.status,
    required this.productTitle,
    required this.priceLabel,
    required this.dateLabel,
    required this.ownerName,
    required this.imagePath,
    required this.cityLabel,
    required this.postalCodeLabel,
    required this.pricePerDay,
    this.onAccept,
    this.onDecline,
    this.onMakeOffer,
    this.onOpenInventory,
    this.onValidateInventory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 TOP ROW : back + owner
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 27,
                  height: 27,
                  decoration: BoxDecoration(
                    color: AppColors.cape200, // gris clair
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 8,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              const SizedBox(width: 12),
              Text(
                ownerName,
                style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 🔹 CARD PRODUIT (inchangée)
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  imagePath,
                  width: 137,
                  height: 113,
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
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.textPrimary,
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
                            "$cityLabel, $postalCodeLabel",
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
                          "${pricePerDay.round()}€ / jour",
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

          const SizedBox(height: 14),

          // 🔹 STATUS / ACTIONS (inchangé)
          _buildStatusArea(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBanner({
    required String text,
    String? linkText,
    VoidCallback? onLinkTap,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.blue50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.22),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (linkText != null && linkText.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onLinkTap,
              child: Text(
                linkText,
                style: AppTextStyles.link.copyWith(
                  color: AppColors.primaryBlue,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusArea(BuildContext context) {
    // 1) Locataire

    if (role == ConversationRole.renter) {
      switch (status) {
        case ReservationStatus.none:
          return Row(
            children: [
              Expanded(
                child: CustomButton(text: "Louer", onPressed: onMakeOffer),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomButton(
                  text: "Faire une offre",
                  outlined: true,
                  onPressed: onMakeOffer,
                ),
              ),
            ],
          );

        case ReservationStatus.requestPending:
          return _buildBanner(
            text: "En attente de la validation du propriétaire",
          );

        case ReservationStatus.accepted:
          return _buildBanner(
            text:
                "Votre demande a été validée. Le jour de l’échange, vous pourrez consulter et valider l’état des lieux.",
          );

        case ReservationStatus.exchangePending:
          return _buildBanner(
            text: "Valider l’état des lieux pour procéder à l’échange.",
            linkText: "Cliquez ici pour consulter l’état des lieux",
            onLinkTap: onOpenInventory,
          );

        case ReservationStatus.completed:
          return _buildBanner(text: "Échange terminé.");
      }
    }

    // 2) Propriétaire
    switch (status) {
      case ReservationStatus.requestPending:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomButton(text: "Valider la demande", onPressed: onAccept),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: onDecline,
              child: Text(
                "Refuser la demande de location",
                style: AppTextStyles.link.copyWith(
                  color: AppColors.primaryRed,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
        );

      case ReservationStatus.accepted:
        return _buildBanner(
          text:
              "Vous avez validé la demande. Au moment de l’échange, vous pourrez réaliser l’état des lieux.",
        );

      case ReservationStatus.exchangePending:
        return Column(
          children: [
            _buildBanner(
              text:
                  "Votre échange est dans moins de 24h. Contrôlez l’état du matériel, photos à l’appui.",
            ),
            const SizedBox(height: 10),
            CustomButton(
              text: "Réaliser l’état des lieux",
              onPressed: onOpenInventory,
            ),
          ],
        );

      case ReservationStatus.none:
      case ReservationStatus.completed:
        return const SizedBox.shrink();
    }
  }
}
