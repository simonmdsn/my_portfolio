import 'package:flutter/material.dart';
import 'package:my_portfolio/widget/media_bar.dart';
import 'package:my_portfolio/widget/top_bar.dart';

class BasePage extends StatefulWidget {
  final Widget child;
  final bool withMediaBar;

  const BasePage({Key? key, required this.child, this.withMediaBar = false}) : super(key: key);

  @override
  _BasePageState createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  Widget _menu = Container();

  void changeMenu(Widget menu) {
    setState(() {
      _menu = menu;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TopBar(
            changeMenu: changeMenu,
          ),
          Stack(
            children: [
              MouseRegion(
                  onEnter: (event) {
                    changeMenu(Container());
                  },
                  child: widget.child),
              _menu,
            ],
          ),
          Spacer(),
          if (widget.withMediaBar) MediaBar(),
        ],
      ),
    );
  }
}
