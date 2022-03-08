import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:js' as js;
import 'package:url_launcher/url_launcher.dart';

// for media such as github, linkedin, email... so on
class MediaBar extends StatelessWidget {
  const MediaBar({Key? key}) : super(key: key);

  static double height = 60.0;

  static mediaButtons() => [
        IconButton(
          onPressed: () =>
              js.context.callMethod('open', ['https://github.com/simonmdsn']),
          icon: Image.asset(
            '/images/github.png',
          ),
          iconSize: 32,
          splashRadius: 24,
          tooltip: 'Take me to Github!',
        ),
        IconButton(
          onPressed: () => js.context.callMethod('open',
              ['https://www.linkedin.com/in/simon-soele-madsen-14b427199/']),
          icon: Image.asset(
            'images/linkedin.png',
          ),
          iconSize: 32,
          splashRadius: 24,
          tooltip: 'Take me to Linkedin!',
        ),
        IconButton(
          onPressed: () async {
            try {
              await launch('mailto:simonmdsn@gmail.com');
            } catch (e) {
              await Clipboard.setData(
                  const ClipboardData(text: 'simonmdsn@gmail.com'));
            }
          },
          icon: const Icon(Icons.mail_outline_outlined),
          iconSize: 32,
          splashRadius: 24,
          tooltip: 'Send me an email',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * .3,
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: mediaButtons(),
      ),
    );
  }
}
