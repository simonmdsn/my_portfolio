import 'package:flutter/material.dart';

class SimonmdsnLogo extends StatefulWidget {
  const SimonmdsnLogo({Key? key}) : super(key: key);

  @override
  State<SimonmdsnLogo> createState() => _SimonmdsnLogoState();
}

class _SimonmdsnLogoState extends State<SimonmdsnLogo> {
  final logoAbbreviated = Text(
    'sm.',
    style: TextStyle(fontSize: 38.0),
    key: UniqueKey(),
  );

  final logo = RichText(
    text: const TextSpan(
      text: 'simon',
    style: TextStyle(fontSize: 38.0),
      children: [
        TextSpan(text: 'mdsn', style: TextStyle(fontSize: 38.0, fontWeight: FontWeight.bold)),
        TextSpan(text: '.')
      ]
    ),
    key: UniqueKey(),
  );

  late Widget _currentLogo;

  @override
  void initState() {
    _currentLogo = logo;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _currentLogo;
  }
}
