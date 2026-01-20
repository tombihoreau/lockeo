import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lockeo_app/theme/app_text_styles.dart';

class Register1Screen extends StatelessWidget {
  const Register1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/fond_bleu_page.png",
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),

                  SvgPicture.asset("assets/icons/logo.svg", height: 34),

                  const SizedBox(height: 100),

                  Text(
                    "Créer votre compte",
                    style: AppTextStyles.hero.copyWith(color: Colors.white),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Inscrivez vous pour découvrir toutes nos fonctionnalités",
                    textAlign: TextAlign.center,
                    style: AppTextStyles.number.copyWith(color: Colors.white),
                  ),

                  const SizedBox(height: 50),

                  _SocialButton(
                    label: "Continuer avec Google",
                    icon: SvgPicture.asset("assets/icons/google.svg"),
                    onTap: () {
                      // TODO Google sign-in
                    },
                  ),
                  const SizedBox(height: 12),

                  _SocialButton(
                    label: "Continuer avec Apple",
                    icon: const Icon(
                      Icons.apple,
                      size: 24,
                      color: Colors.black,
                    ),
                    onTap: () {
                      // TODO Apple sign-in
                    },
                  ),
                  const SizedBox(height: 16),

                  _SocialButton(
                    label: "Continuer avec mon email",
                    icon: const Icon(
                      Icons.email_outlined,
                      size: 24,
                      color: Colors.black,
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, "/register_2");
                    },
                  ),

                  const SizedBox(height: 16),

                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, "/login"),
                    child: Text(
                      "Déjà un compte",
                      style: AppTextStyles.link.copyWith(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                        ),
                    ),
                  ),

                  const Spacer(),

                  // petit padding bas pour respirer
                  SizedBox(height: 20 + MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(48),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            SizedBox(width: 30, child: Center(child: icon)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(color: Colors.black),
              ),
            ),
            const SizedBox(width: 34), // équilibre à droite
          ],
        ),
      ),
    );
  }
}
