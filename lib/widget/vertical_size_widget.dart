import 'package:flutter/material.dart';

class VerticalSizeAnimation extends StatefulWidget {
  final Widget child;

  const VerticalSizeAnimation({Key? key, required this.child}) : super(key: key);

  @override
  _VerticalSizeAnimationState createState() => _VerticalSizeAnimationState();
}

class _VerticalSizeAnimationState extends State<VerticalSizeAnimation>
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
      axis: Axis.vertical,
      axisAlignment: -1,
      child: widget.child,
    );
  }
}
