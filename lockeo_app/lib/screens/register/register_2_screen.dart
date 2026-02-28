import 'package:flutter/material.dart';
import 'package:lockeo_app/utils/app_navigator.dart';
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
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _pwdConfirmCtrl = TextEditingController();

  bool _obscurePwd = true;
  bool _obscureConfirm = true;
  bool _acceptedCgu = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _pwdCtrl.dispose();
    _pwdConfirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_acceptedCgu) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez accepter les conditions générales d’utilisation."),
        ),
      );
      return;
    }

    Navigator.pushNamed(context, '/register_3');
  }

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
                        onTap: () => AppNavigator.back(context),
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
                        const SizedBox(height: 12),

                        Center(
                          child: SvgPicture.asset(
                            "assets/icons/logo.svg",
                            height: 35,
                          ),
                        ),

                        const SizedBox(height: 28),

                        Text(
                          "Créer votre compte",
                          style: AppTextStyles.hero.copyWith(
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 16),

                        _Label("Votre e-mail"),
                        const SizedBox(height: 8),
                        _TextFieldWhite(
                          controller: _emailCtrl,
                          hintText: "Votre adresse e-mail",
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          obscureText: false,
                        ),

                        const SizedBox(height: 12),

                        _Label("Votre prénom"),
                        const SizedBox(height: 8),
                        _TextFieldWhite(
                          controller: _firstNameCtrl,
                          hintText: "Votre prénom",
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          obscureText: false,
                        ),

                        const SizedBox(height: 12),

                        _Label("Votre nom"),
                        const SizedBox(height: 8),
                        _TextFieldWhite(
                          controller: _lastNameCtrl,
                          hintText: "Votre nom",
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          obscureText: false,
                        ),

                        const SizedBox(height: 12),

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

                        const SizedBox(height: 6),

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
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _acceptedCgu,
                              onChanged: (value) {
                                setState(() => _acceptedCgu = value ?? false);
                              },
                              side: const BorderSide(
                                color: Colors.white,
                                width: 2,
                              ),
                              checkColor: AppColors.primaryBlue,
                              activeColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 1),
                              child: RichText(
                                text: TextSpan(
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white,
                                  ),
                                  children: const [
                                    TextSpan(text: "J’accepte les "),
                                    TextSpan(
                                      text: "conditions générales d’utilisation.",
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 64,
                        child: ElevatedButton(
                          onPressed: _submit,
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
                    ],
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
