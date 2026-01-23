import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lockeo_app/theme/app_text_styles.dart';
import '../../widgets/loop_rotate.dart';

class Register3Screen extends StatelessWidget {
  const Register3Screen({super.key});

  void _resendMail(BuildContext context) {
    Navigator.pushNamed(context, "/register_4");
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text("Mail de confirmation renvoyé")),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fond (asset)
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),

                  // Logo
                  Center(
                    child: SvgPicture.asset(
                      "assets/icons/logo.svg",
                      height: 35,
                    ),
                  ),

                  const SizedBox(height: 100),

                  Text(
                    "Activation de votre\ncompte",
                    style: AppTextStyles.hero.copyWith(
                      color: Colors.white,
                      height: 1.15,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    "Nous avons envoyé un mail, pour que\n"
                    "vous puissiez activer votre compte.",
                    style: AppTextStyles.number.copyWith(
                      color: Colors.white,
                      height: 1.35,
                    ),
                  ),

                  const SizedBox(height: 24),
                  Center(
                    child: LoopRotateWithPause(
                      rotateDuration: const Duration(milliseconds: 1500),
                      pauseDuration: const Duration(milliseconds: 900),
                      child: Image.asset(
                        "assets/images/hourglass.png",
                        height: 174,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Center(
                    child: Column(
                      children: [
                        Text(
                          "Vous n’avez pas reçu de mail ?",
                          style: AppTextStyles.link.copyWith(
                            color: Colors.white,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 6),

                        GestureDetector(
                          onTap: () => _resendMail(context),
                          child: Text(
                            "Renvoyer un nouveau mail de confirmation",
                            style: AppTextStyles.link.copyWith(
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
