import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../widgets/button.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CreateOfferEndScreen extends StatelessWidget {
  final String offerTitle;
  final String offerDescription;
  final String offerImagePath;
  final int offerCount; // ex: 15ème annonce

  const CreateOfferEndScreen({
    super.key,
    required this.offerTitle,
    required this.offerDescription,
    required this.offerImagePath,
    required this.offerCount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          "Confirmation d'annonce",
          style: TextStyle(color: Colors.black),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),

            SvgPicture.asset( 
              'assets/icons/icon_check.svg',
              width: 80,
              height: 80,
            ),
            const SizedBox(height: 25),

            // Titre
            const Text(
              "Votre annonce a été ajoutée !",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "Vous venez de poster votre $offerCountᵉ annonce",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 30),

            // Carte de l’annonce
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        offerImagePath,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Texte
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offerTitle,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            offerDescription,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 8),

                          GestureDetector(
                            onTap: () {
                              // Naviguer vers l'annonce
                            },
                            child: const Text(
                              "Découvrir mon annonce →",
                              style: TextStyle(
                                color: Color(0xFF00434A),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Retour à l'accueil
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/');
              },
              child: const Text(
                "Retour à la page d’accueil",
                style: TextStyle(
                  color: Color(0xFFB17815),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 120),
          ],
        ),
      ),

     bottomNavigationBar: Container(
        color: Colors.white,
        alignment: Alignment.center,
        height: 100,
        child: SizedBox(
          width: 300,
          child: CustomButton(
            text: "Ajouter une nouvelle annonce",
            onPressed: () {Navigator.pushNamed(context, '/create');}
          ),
        ),
      ),
    );
  }
}
