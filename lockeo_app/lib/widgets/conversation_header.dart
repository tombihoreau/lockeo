import 'package:flutter/material.dart';
import 'package:lockeo_app/utils/app_navigator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../widgets/button.dart';
import '../widgets/selected_photo_image.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum ConversationRole { renter, owner }

enum ReservationStatus {
  none,
  requestPending,
  accepted,
  exchangePending,
  completed,
  cancelled,

  // ✅ Objet chez le locataire
  inProgress, // tu l'as jusqu'à...
  returnSoon, // rendu dans moins de 24h
  checkoutValidated, // état des lieux de sortie validé
}

class ConversationHeader extends StatelessWidget {
  final ConversationRole role;
  final ReservationStatus status;

  final String productTitle;
  final String priceLabel;
  final String dateLabel;
  final String otherUserName;
  final String imagePath;
  final double? totalPrice;
  final int? totalDays;

  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onMakeOffer;
  final VoidCallback? onOpenOfferDetails;
  final VoidCallback? onOpenInventory;
  final VoidCallback? onValidateInventory;

  final String cityLabel;
  final String postalCodeLabel;
  final double pricePerDay;

  // ✅ Pour “tu l'as jusqu'au …”
  final DateTime? rentalEndDate;

  const ConversationHeader({
    super.key,
    required this.role,
    required this.status,
    required this.productTitle,
    required this.priceLabel,
    required this.dateLabel,
    required this.otherUserName,
    required this.imagePath,
    this.totalPrice,
    this.totalDays,
    required this.cityLabel,
    required this.postalCodeLabel,
    required this.pricePerDay,
    this.rentalEndDate,
    this.onAccept,
    this.onDecline,
    this.onMakeOffer,
    this.onOpenOfferDetails,
    this.onOpenInventory,
    this.onValidateInventory,
  });

  String get _locationLabel {
    final city = cityLabel.trim();
    final postalCode = _sanitizePostalCode(postalCodeLabel);

    if (city.isNotEmpty && postalCode.isNotEmpty) {
      return "$city, $postalCode";
    }
    if (city.isNotEmpty) return city;
    if (postalCode.isNotEmpty) return postalCode;
    return "";
  }

  String _sanitizePostalCode(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return "";
    if (RegExp(r'^0+$').hasMatch(normalized)) {
      return "";
    }
    return normalized;
  }

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    if (keyboardVisible) {
      return const SizedBox.shrink();
    }

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
                onTap: () => AppNavigator.back(context),
                child: Container(
                  width: 27,
                  height: 27,
                  decoration: const BoxDecoration(
                    color: AppColors.cape200,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 10,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                otherUserName,
                style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 🔹 CARD PRODUIT
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SelectedPhotoImage(
                  path: imagePath,
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
                            _locationLabel,
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

          // 🔹 STATUS / ACTIONS
          _buildStatusArea(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // -------------------------
  // BANNERS
  // -------------------------

  Widget _buildBanner({
    Widget? leading,
    String? title,
    String? body,
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
          color: AppColors.primaryBlue.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null) ...[leading, const SizedBox(width: 10)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null && title.trim().isNotEmpty)
                  Text(
                    title,
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                if (body != null && body.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    body,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
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
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptedBanner(role) {
    const title = "Votre demande a été validée";
    String body = "";
    if (role == 'loc') {
      body =
          "Le jour de l’échange, vous pourrez consulter et valider l’état des lieux.";
    } else {
      body =
          "Au moment de l’échange, vous pourrez réaliser l’état des lieux du matériel.";
    }
    return _buildBanner(
      leading: SvgPicture.asset(
        'assets/icons/icon_check.svg',
        width: 27,
        height: 27,
      ),
      title: title,
      body: body,
    );
  }

  String get _requestSummaryTitle {
    final safeDays = totalDays ?? 0;
    if (safeDays <= 0) return "Demande de location";
    return "Demande de location • $safeDays ${safeDays > 1 ? 'jours' : 'jour'}";
  }

  Widget _buildRequestCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.blue50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _requestSummaryTitle,
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (totalPrice != null)
                Text(
                  "${totalPrice!.toStringAsFixed(2)}€",
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
            ],
          ),
          if (dateLabel.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.calendar_month,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    dateLabel,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
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
      ),
    );
  }

  String _untilLabel(DateTime? endDate) {
    if (endDate == null) return "";
    final df = DateFormat("d MMMM y", "fr_FR");
    String cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
    return "Location active jusqu’au ${cap(df.format(endDate))}.";
  }

  // -------------------------
  // STATUS LOGIC
  // -------------------------

  Widget _buildStatusArea(BuildContext context) {
    // ✅ Locataire
    if (role == ConversationRole.renter) {
      switch (status) {
        case ReservationStatus.none:
        case ReservationStatus.checkoutValidated:
          return Row(
            children: [
              Expanded(
                child: CustomButton(text: "Louer", onPressed: onMakeOffer),
              ),
              const SizedBox(width: 10),
            ],
          );

        case ReservationStatus.requestPending:
          return _buildBanner(
            title: "En attente de la validation du propriétaire",
            body: dateLabel,
          );

        case ReservationStatus.accepted:
          return _buildAcceptedBanner('loc');

        case ReservationStatus.exchangePending:
          return _buildBanner(
            body: "Valider l’état des lieux pour procéder à l’échange.",
            linkText: "Cliquez ici pour consulter l’état des lieux",
            onLinkTap: onOpenInventory,
          );

        // ✅ OBJET CHEZ LE LOCATAIRE
        case ReservationStatus.inProgress:
          return _buildBanner(
            title: "Location en cours",
            body:
                "${_untilLabel(rentalEndDate)} \nUn état des lieux sera réalisé au moment de la remise.",
          );

        case ReservationStatus.returnSoon:
          return _buildBanner(
            title: "Votre rendu est dans moins de 24h",
            body:
                "Lors de l’échange, le propriétaire va vérifier l’état du matériel.",
          );

        case ReservationStatus.completed:
          return _buildBanner(title: "Échange terminé.");

        case ReservationStatus.cancelled:
          return _buildBanner(title: "Réservation annulée.");
      }
    }

    // ✅ Propriétaire
    switch (status) {
      case ReservationStatus.requestPending:
        return _buildRequestCard();

      case ReservationStatus.accepted:
        return _buildAcceptedBanner('proprietaire');

      case ReservationStatus.exchangePending:
        return Column(
          children: [
            _buildBanner(
              title: "Votre échange est dans moins de 24h.",
              body: "Contrôlez l’état du matériel, photos à l’appui.",
            ),
            const SizedBox(height: 10),
            CustomButton(
              text: "Réaliser l’état des lieux",
              onPressed: onOpenInventory,
            ),
          ],
        );

      case ReservationStatus.inProgress:
        return _buildBanner(
          title: "Location en cours",
          body:
              "${_untilLabel(rentalEndDate)} \nUn état des lieux sera réalisé au moment de la remise.",
        );

      case ReservationStatus.returnSoon:
        return Column(
          children: [
            _buildBanner(
              title: "Récupérez votre matériel dans moins de 24h",
              body:
                  "Contrôler l’état de votre matériel (défauts, photos), durant l’état des lieux.",
            ),
            const SizedBox(height: 10),
            CustomButton(
              text: "Vérifier le matériel",
              onPressed: onOpenInventory,
            ),
          ],
        );

      case ReservationStatus.none:
      case ReservationStatus.completed:
      case ReservationStatus.cancelled:
      case ReservationStatus.checkoutValidated:
        return const SizedBox.shrink();
    }
  }
}
