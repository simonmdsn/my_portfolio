import 'package:flutter/cupertino.dart';
import 'package:my_portfolio/page/home_page.dart';
import 'package:my_portfolio/page/tools/chat_page.dart';
import 'package:my_portfolio/page/tools/strings_page.dart';
import 'package:my_portfolio/page/tools/ubuntu/ubuntu_page.dart';

class RouteNames {
  static const homePage = '/home';

  static const tools = '/tools';

  static const stringPage = tools + '/strings';
  static const ubuntuPage = tools + '/ubuntu';
  static const chatPage = tools + '/chat';



  static const List<String> toolsPages = [
    stringPage,
    ubuntuPage,
    chatPage,
  ];
}

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.homePage:
        return _GeneratePageRoute(
            widget: const HomePage(), routeName: settings.name!);
      case RouteNames.stringPage:
        return _GeneratePageRoute(
            widget: const StringsPage(), routeName: settings.name!);
      case RouteNames.ubuntuPage:
        return _GeneratePageRoute(
            widget: const UbuntuPage(), routeName: settings.name!);
      case RouteNames.chatPage:
        return _GeneratePageRoute(widget: const ChatPage(), routeName: settings.name!);
      default:
        return _GeneratePageRoute(
            widget: const HomePage(), routeName: settings.name!);
    }
  }
}

class _GeneratePageRoute extends PageRouteBuilder {
  final Widget widget;
  final String routeName;

  _GeneratePageRoute({required this.widget, required this.routeName})
      : super(
            settings: RouteSettings(name: routeName),
            pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation) {
              return widget;
            },
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (BuildContext context,
                Animation<double> animation,
                Animation<double> secondaryAnimation,
                Widget child) {
              return SlideTransition(
                textDirection: TextDirection.rtl,
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            });
}
