import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_portfolio/main.dart';

class ThemeSwitcher extends ConsumerWidget {
  const ThemeSwitcher({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = ref.watch(appThemeStateNotifier);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          appTheme.isDarkMode ? appTheme.setLightTheme() : appTheme.setDarkTheme();
        },
        child: appTheme.isDarkMode
            ? Icon(Icons.dark_mode_outlined)
            : Icon(Icons.light_mode_outlined),
      ),
    );
  }
}
