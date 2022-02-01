import 'package:flutter/material.dart';
import 'package:my_portfolio/config/global_key_extension.dart';
import 'package:my_portfolio/config/routes.dart';
import 'package:my_portfolio/config/string_utils.dart';
import 'package:my_portfolio/widget/simonmdsn_logo.dart';
import 'package:my_portfolio/widget/theme_switcher.dart';

class TopBar extends StatefulWidget {
  Function(Widget) changeMenu;

  TopBar({Key? key, required this.changeMenu}) : super(key: key);

  @override
  _TopBarState createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 100,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed(RouteNames.homePage),
                  child: const SimonmdsnLogo(),
                ),
              ),
              ToolsDropdownButton(
                key: GlobalKey(),
                changeMenu: widget.changeMenu,
              ),
              MouseRegion(
                child: GestureDetector(
                  child: Text(
                    'blog.',
                    style: TextStyle(fontSize: 24.0),
                  ),
                  onTap: () => print('go to blog'),
                ),
                cursor: SystemMouseCursors.click,
              ),
              ThemeSwitcher(),
            ],
          ),
        ),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey))),
      ),
    );
  }
}

class ToolsDropdownButton extends StatefulWidget {
  Function(Widget) changeMenu;

  ToolsDropdownButton({Key? key, required this.changeMenu}) : super(key: key);

  @override
  _ToolsDropdownButtonState createState() => _ToolsDropdownButtonState();
}

class _ToolsDropdownButtonState extends State<ToolsDropdownButton> {
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      child: Text(
        '↓ tools.',
        style: TextStyle(fontSize: 24.0),
      ),
      cursor: SystemMouseCursors.click,
      onHover: (event) {
        widget.changeMenu(ToolsDropdownMenu(
          parentPosition: (widget.key! as GlobalKey).globalPaintBounds!,
        ));
      },
    );
  }
}

class ToolsDropdownMenu extends StatefulWidget {
  final Rect parentPosition;

  const ToolsDropdownMenu({Key? key, required this.parentPosition})
      : super(key: key);

  @override
  _ToolsDropdownMenuState createState() => _ToolsDropdownMenuState();
}

class _ToolsDropdownMenuState extends State<ToolsDropdownMenu> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.parentPosition.left,
      child: Container(
        color: const Color(0xFFEEEEEE),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: RouteNames.toolsPages
              .map((e) => MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, e),
                      child: Text(e.split('/').last.capitalize()))))
              .toList(),
        ),
      ),
    );
  }
}
