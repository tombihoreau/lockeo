import 'package:flutter/material.dart';
import 'register_welcome_page1_screen.dart';
import 'register_welcome_page2_screen.dart';
import 'register_welcome_page3_screen.dart';

class RegisterWelcomePagesScreen extends StatefulWidget {
  const RegisterWelcomePagesScreen({super.key});

  @override
  State<RegisterWelcomePagesScreen> createState() =>
      _RegisterWelcomePagesScreenState();
}

class _RegisterWelcomePagesScreenState
    extends State<RegisterWelcomePagesScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _skip() {
    _controller.animateToPage(
      2,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fond commun
          Positioned.fill(
            child: Image.asset(
              "assets/images/fond_bleu_page.png",
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Stack(
              children: [
                PageView(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _index = i),
                  children: const [
                    RegisterWelcomePage1Screen(),
                    RegisterWelcomePage2Screen(),
                    RegisterWelcomePage3Screen(),
                  ],
                ),

                // Passer cette étape
                Positioned(
                  top: 10,
                  right: 18,
                  child: GestureDetector(
                    onTap: _skip,
                    child: Row(
                      children: const [
                        Text(
                          "Passer cette étape",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),

                // Dots
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 18 + MediaQuery.of(context).padding.bottom,
                  child: Positioned(
                    left: 0,
                    right: 0,
                    bottom: 18 + MediaQuery.of(context).padding.bottom,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (i) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _index ? 16 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(
                              i == _index ? 1 : 0.4,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
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
