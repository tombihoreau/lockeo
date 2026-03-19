import 'package:flutter/material.dart';

class LoopRotateWithPause extends StatefulWidget {
  final Widget child;
  final Duration? rotateDuration;
  final Duration pauseDuration;

  const LoopRotateWithPause({
    super.key,
    required this.child,
    this.rotateDuration,
    this.pauseDuration = const Duration(milliseconds: 900),
  });

  @override
  State<LoopRotateWithPause> createState() => _LoopRotateWithPauseState();
}

class _LoopRotateWithPauseState extends State<LoopRotateWithPause>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.rotateDuration,
    );

    _loop();
  }

  Future<void> _loop() async {
    while (mounted) {
      // 1 tour complet
      await _controller.forward(from: 0);

      // pause
      await Future.delayed(widget.pauseDuration);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut, 
      ),
      child: widget.child,
    );
  }
}
