import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lockeo_app/theme/app_text_styles.dart';
import 'package:lockeo_app/theme/app_colors.dart';

class Register2Screen extends StatefulWidget {
  const Register2Screen({super.key});

  @override
  State<Register2Screen> createState() => _Register2ScreenState();
}

class _Register2ScreenState extends State<Register2Screen> {
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _pwdConfirmCtrl = TextEditingController();

  bool _obscurePwd = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    _pwdConfirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    // TODO: branche ton inscription
    // Pour l’instant, tu peux naviguer vers une prochaine page si tu veux :
    // Navigator.pushNamed(context, "/register_3");
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

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
            child: Column(
              children: [
                // Top bar (Retour)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () => Navigator.pop(context),
                        child: Row(
                          children: const [
                            SizedBox(width: 4),
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.chevron_left,
                                color: Colors.black,
                                size: 22,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Retour",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),

                // Content scrollable
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 18),

                        Center(
                          child: SvgPicture.asset(
                            "assets/icons/logo.svg",
                            height: 35,
                          ),
                        ),

                        const SizedBox(height: 70),

                        Text(
                          "Créer votre compte",
                          style: AppTextStyles.hero.copyWith(
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          "Lorem ipsum dolor sit amet consectetur.\n"
                          "Sit viverra donec quis dignissim. Fames.",
                          style: AppTextStyles.number.copyWith(
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 22),

                        _Label("Votre e-mail"),
                        const SizedBox(height: 8),
                        _TextFieldWhite(
                          controller: _emailCtrl,
                          hintText: "Votre adresse e-mail",
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          obscureText: false,
                        ),

                        const SizedBox(height: 18),

                        _Label("Création du mot de passe"),
                        const SizedBox(height: 8),
                        _TextFieldWhite(
                          controller: _pwdCtrl,
                          hintText: "Mot de passe",
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.next,
                          obscureText: _obscurePwd,
                          suffix: IconButton(
                            onPressed: () =>
                                setState(() => _obscurePwd = !_obscurePwd),
                            icon: Icon(
                              _obscurePwd
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.black54,
                              size: 20,
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          "1 majuscule, 1 chiffre, 1 caractère spécial et 8 caractères min.",
                          style: AppTextStyles.label.copyWith(
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 14),

                        _Label("Confirmation du mot de passe"),
                        const SizedBox(height: 8),
                        _TextFieldWhite(
                          controller: _pwdConfirmCtrl,
                          hintText: "Mot de passe",
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.done,
                          obscureText: _obscureConfirm,
                          suffix: IconButton(
                            onPressed: () => setState(
                              () => _obscureConfirm = !_obscureConfirm,
                            ),
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.black54,
                              size: 20,
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),

                // Bottom button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register_3');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryRed,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: Text(
                        "CRÉER MON COMPTE",
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.primaryRed,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.caption.copyWith(color: Colors.white),
    );
  }
}

class _TextFieldWhite extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final Widget? suffix;

  const _TextFieldWhite({
    required this.controller,
    required this.hintText,
    required this.keyboardType,
    required this.textInputAction,
    required this.obscureText,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: obscureText,
        style: AppTextStyles.body.copyWith(color: Colors.black),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: hintText,
          hintStyle: AppTextStyles.label.copyWith(color: AppColors.textGrey),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          suffixIcon: suffix,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
