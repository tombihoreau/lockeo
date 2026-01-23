import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lockeo_app/theme/app_text_styles.dart';

class Register5Screen extends StatelessWidget {
  const Register5Screen({super.key});

  void _goHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void _openRefuseDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true, // tu peux laisser true si tu veux
      builder: (_) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 22),
          backgroundColor: Colors.transparent,
          child: _RefuseLocationDialog(
            onContinue: () {
              // important : fermer la dialog AVANT de naviguer
              Navigator.of(context, rootNavigator: true).pop();
              Future.microtask(() => _goHome(context));
            },
          ),
        );
      },
    );
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
                const SizedBox(height: 18),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => _goHome(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/',
                                (route) => false,
                              );
                            },
                            child: Text(
                              "Passer cette étape",
                              style: AppTextStyles.link.copyWith(
                                color: Colors.white,
                                decorationColor: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: const Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                SvgPicture.asset("assets/icons/logo.svg", height: 35),

                const SizedBox(height: 72),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Trouve du matériel\nproche de chez toi !",
                        style: AppTextStyles.hero.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Lockeo utilise ta position pour te proposer du matériel sportif disponible autour de toi et faciliter les échanges locaux.",
                        style: AppTextStyles.number.copyWith(
                          color: Colors.white,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                  child: SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: () => _goHome(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: const Text(
                        "AUTORISER LA LOCALISATION",
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFD1380D),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () => _openRefuseDialog(context),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Text(
                      "Refuser la localisation",
                      style: AppTextStyles.link.copyWith(
                        color: Colors.white,
                        decorationColor: Colors.white,
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

class _RefuseLocationDialog extends StatefulWidget {
  final VoidCallback onContinue;

  const _RefuseLocationDialog({required this.onContinue});

  @override
  State<_RefuseLocationDialog> createState() => _RefuseLocationDialogState();
}

class _RefuseLocationDialogState extends State<_RefuseLocationDialog> {
  late final TextEditingController _codeCtrl;

  @override
  void initState() {
    super.initState();
    _codeCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  void _close() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              GestureDetector(
                onTap: _close,
                child: const Icon(Icons.close, size: 22, color: Colors.black),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            "Indique ta zone de\nrecherche",
            textAlign: TextAlign.center,
            style: AppTextStyles.h1.copyWith(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            "Sans activer la localisation, Lockeo peut quand même te proposer du matériel sportif près de chez toi grâce à ton code postal.",
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              color: Colors.black,
              height: 1.25,
            ),
          ),

          const SizedBox(height: 18),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Titre",
              style: AppTextStyles.label.copyWith(color: Colors.black),
            ),
          ),
          const SizedBox(height: 8),

          TextField(
            controller: _codeCtrl,
            keyboardType: TextInputType.number,
            textAlignVertical: TextAlignVertical.center,
            style: AppTextStyles.body.copyWith(color: Colors.black),
            decoration: InputDecoration(
              hintText: "Ex 14000",
              hintStyle: AppTextStyles.label.copyWith(
                color: Colors.black.withOpacity(0.25),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFFD1380D),
                  width: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: widget.onContinue,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFD1380D), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                "CONTINUER",
                style: AppTextStyles.button.copyWith(
                  color: const Color(0xFFD1380D),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
