import 'package:flutter/material.dart';
import '../widgets/custom_navbar.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final bool showBottomBar;

  const MainScaffold({
    super.key,
    required this.child,
    required this.currentIndex,
    this.showBottomBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: showBottomBar ? CustomBottomNavBar(currentIndex: currentIndex) : null,
    );
  }
}
