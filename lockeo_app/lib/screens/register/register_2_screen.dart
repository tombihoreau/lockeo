import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lockeo_app/services/auth_service.dart';
import 'package:lockeo_app/theme/app_text_styles.dart';
import 'package:lockeo_app/theme/app_colors.dart';

class Register2Screen extends StatefulWidget {
  const Register2Screen({super.key});

  @override
  State<Register2Screen> createState() => _Register2ScreenState();
}

class _Register2ScreenState extends State<Register2Screen> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _pwdConfirmCtrl = TextEditingController();

  bool _submitting = false;

  bool _obscurePwd = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    _pwdConfirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_submitting) return;

    final firstName = _firstNameCtrl.text.trim();
    final lastName = _lastNameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pwd = _pwdCtrl.text;
    final pwdConfirm = _pwdConfirmCtrl.text;

    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || pwd.isEmpty || pwdConfirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Merci de remplir tous les champs.')),
      );
      return;
    }

    if (pwd != pwdConfirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les mots de passe ne correspondent pas.')),
      );
      return;
    }

    setState(() => _submitting = true);

    AuthService()
        .register(
          email: email,
          firstName: firstName,
          lastName: lastName,
          password: pwd,
          passwordConfirm: pwdConfirm,
        )
        .then((_) {
      if (!mounted) return;
      Navigator.pushNamed(context, '/register_3');
    }).catchError((e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Inscription impossible: $e')),
      );
    }).whenComplete(() {
      if (!mounted) return;
      setState(() => _submitting = false);
    });
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

                        const SizedBox(height: 40),

                        Text(
                          "Créer votre compte",
                          style: AppTextStyles.hero.copyWith(
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 10),


                        const SizedBox(height: 22),

                        _Label("Votre prénom"),
                        const SizedBox(height: 8),
                        _TextFieldWhite(
                          controller: _firstNameCtrl,
                          hintText: "Prénom",
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          obscureText: false,
                        ),

                        const SizedBox(height: 18),

                        _Label("Votre nom"),
                        const SizedBox(height: 8),
                        _TextFieldWhite(
                          controller: _lastNameCtrl,
                          hintText: "Nom",
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          obscureText: false,
                        ),

                        const SizedBox(height: 18),

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
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryRed,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Color(0xFFD1380D),
                              ),
                            )
                          : Text(
                              "CRÉER MON COMPTE",
                              style: AppTextStyles.button.copyWith(
                                color: const Color(0xFFD1380D),
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
        style: AppTextStyles.caption.copyWith(color: Colors.black),
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
