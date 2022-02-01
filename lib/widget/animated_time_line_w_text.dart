import 'package:flutter/material.dart';

class AnimatedTimeLineWText extends StatefulWidget {
  late AnimationController animationController;
  final String text;

  AnimatedTimeLineWText({Key? key, required this.text}) : super(key: key);

  @override
  _AnimatedTimeLineWTextState createState() => _AnimatedTimeLineWTextState();
}

class _AnimatedTimeLineWTextState extends State<AnimatedTimeLineWText>
    with SingleTickerProviderStateMixin {
  late final Animation<double> _animation;

  @override
  void initState() {
    widget.animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: widget.animationController,
      curve: Curves.fastOutSlowIn,
    );
    widget.animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    widget.animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizeTransition(
          sizeFactor: _animation,
          axis: Axis.vertical,
          axisAlignment: -1,
          child: Center(
            child: Container(
              color: Colors.grey,
              child: const SizedBox(
                width: 2,
                height: 60,
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Flexible(
          fit: FlexFit.loose,
          child: FadeTransition(
            opacity: _animation,
            child: Text(
              widget.text,
              style: const TextStyle(fontSize: 16.0),
              overflow: TextOverflow.fade,
            ),
          ),
        ),
      ],
    );
  }
}
