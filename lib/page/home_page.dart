import 'package:flutter/material.dart';
import 'package:my_portfolio/page/base_page.dart';
import 'package:my_portfolio/widget/animated_time_line_w_text.dart';
import 'package:my_portfolio/widget/fade_widget.dart';
import 'package:my_portfolio/widget/vertical_size_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final education = [
    AnimatedTimeLineWText(
      text: '2018 - 2021 BSc in Engineering - Software Engineering',
    ),
    AnimatedTimeLineWText(
      text: '2021 - 2023 MSc in Engineering - Software Engineering',
    ),
  ];

  final experience = [
    AnimatedTimeLineWText(
      text:
          '2019 - 2021 Student Developer at the Maersk Mc-Kinney Moller Institute',
    ),
    AnimatedTimeLineWText(
      text:
          '2019 - 2021 Student Instructor at the University of Southern Denmark in Database Management',
    ),
  ];

  final other = [
    AnimatedTimeLineWText(
        text:
            'Winner of Audio Explorers 2019 Software Challenge by Oticon - with a trip to New York City')
  ];

  final about = 'Hello, my name is Simon. I am from Denmark, and I study'
      ' Software Engineering at the University of Southern Denmark. '
      ' I do full-stack and mobile app development.'
      ' My favorite programming language is Dart, but am well-versed in Java, Python, and JavaScript.'
      ' For full-stack development I usually use, from top to bottom,'
      ' Flutter web / Angular, Spring, MongoDB / Postgres, sprinkled with MQTT, WebSockets, and / or OPC'
      ' depending on the use case. Mobile development is done solely with Flutter.'
      ' Notably projects involve developing, scaling, and maintaining IoT systems for consumer'
      ' markets.'
      ' Personally, I love educating others, which I do alongside my studies.';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      child: Center(
        child: Column(
          children: [
            Wrap(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: buildTimeline(),
                ),
                Wrap(
                  children: [
                    SizedBox(
                      width: 600,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const FadeWidget(
                              child: Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Text('about me.',
                                style: TextStyle(fontSize: 36.0)),
                          )),
                          VerticalSizeAnimation(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                about,
                                style: const TextStyle(
                                    fontSize: 18.0, height: 1.75),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Divider(),
            Wrap(
              children: [
                  SizedBox(
                    width: 600,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeWidget(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                'this website.',
                                style: TextStyle(fontSize: 36.0),
                              ),
                            ),
                        ),
                VerticalSizeAnimation(
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'I built this website to showcase my skills with Flutter.',
                        style: const TextStyle(fontSize: 18.0, height: 1.75),
                      ),
                  ),
                ),
                      ],
                    ),
                  ),
                Wrap(
                  children: [
                    SizedBox(
                      width: 600,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        ],
                      ),
                    )
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  SizedBox buildTimeline() {
    return SizedBox(
      width: 600,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const FadeWidget(
                child: Text('education.', style: TextStyle(fontSize: 36.0))),
            ...education,
            const FadeWidget(
                child: Text('experience.', style: TextStyle(fontSize: 36.0))),
            ...experience,
            const FadeWidget(
                child: Text(
              'other.',
              style: TextStyle(fontSize: 36.0),
            )),
            ...other,
          ],
        ),
      ),
    );
  }
}
