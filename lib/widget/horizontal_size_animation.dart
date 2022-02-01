import 'package:flutter/material.dart';

class HorizontalSizeAnimation extends StatefulWidget {
  final Widget child;

  const HorizontalSizeAnimation({Key? key, required this.child}) : super(key: key);

  @override
  _HorizontalSizeAnimationState createState() => _HorizontalSizeAnimationState();
}

class _HorizontalSizeAnimationState extends State<HorizontalSizeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.linear,
  );

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _animation,
      axis: Axis.horizontal,
      axisAlignment: -1,
      child: widget.child,
    );
  }
}
