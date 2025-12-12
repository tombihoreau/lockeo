import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/button.dart';

class ReservationConfirmationScreen extends StatelessWidget {
  const ReservationConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 50),

              // ✅ Icône check
              SvgPicture.asset(
                'assets/icons/icon_check.svg',
                width: 64,
                height: 64,
              ),

              const SizedBox(height: 24),

              // 🎉 Titre
              const Text(
                "Votre Demande A Été\nEnvoyée !",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 16),

              // 📝 Texte explicatif
              const Text(
                "Vous recevrez un e-mail de confirmation dès que le propriétaire aura validé votre demande.\n\nJusqu'au 20/10/2025",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, height: 1.4),
              ),

              const SizedBox(height: 32),

              // 📦 Carte réservation
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    // Image produit
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/default.jpg',
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Infos
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Tenue de ski",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "27 févr 12h00 → 28 févr 12h00",
                            style: TextStyle(color: Colors.black54),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  "Rennes, quartier Leon Bourgeois",
                                  style: TextStyle(color: Colors.grey),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: const [
                              Text(
                                "Contacter le propriétaire",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2E6F75),
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(
                                Icons.chevron_right,
                                color: Color(0xFF2E6F75),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // 🔘 Bouton retour accueil
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        alignment: Alignment.center,
        height: 100,
        child: SizedBox(
          width: 300,
          child: CustomButton(
            text: "Retour à la page d’accueil",
            onPressed: () {Navigator.pushNamed(context, '/');}
          ),
        ),
      ),
    );
  }
}
