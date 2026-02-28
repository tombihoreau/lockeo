import 'package:flutter/material.dart';

class AppNavigator {
  const AppNavigator._();

  static Future<void> back(
    BuildContext context, {
    WidgetBuilder? fallbackBuilder,
  }) async {
    final didPop = await Navigator.maybePop(context);
    if (didPop || fallbackBuilder == null) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, _, __) => fallbackBuilder(context),
        transitionDuration: const Duration(milliseconds: 260),
        reverseTransitionDuration: const Duration(milliseconds: 260),
        transitionsBuilder: (_, animation, __, child) {
          final offset = Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          );
          return SlideTransition(position: offset, child: child);
        },
      ),
    );
  }
}
