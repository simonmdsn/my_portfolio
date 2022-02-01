import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_portfolio/config/routes.dart';
import 'package:my_portfolio/page/home_page.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class AppThemeState extends ChangeNotifier {
  var isDarkMode = true;

  void setLightTheme() {
    isDarkMode = false;
    notifyListeners();
  }

  void setDarkTheme() {
    isDarkMode = true;
    notifyListeners();
  }
}

final appThemeStateNotifier = ChangeNotifierProvider((ref) => AppThemeState());

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appThemeState = ref.watch(appThemeStateNotifier);
    return MaterialApp(
      title: 'simonmdsn',
      theme:
          ThemeData.light().copyWith(textTheme: GoogleFonts.ubuntuTextTheme()),
      darkTheme: ThemeData.dark().copyWith(
        iconTheme: IconThemeData(color: Colors.white70),
          textTheme: GoogleFonts.ubuntuTextTheme(
              ThemeData(brightness: Brightness.dark).textTheme.apply(bodyColor: Colors.white70,displayColor: Colors.white70))),
      themeMode:
          appThemeState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      onGenerateRoute: RouteGenerator.generateRoute,
      initialRoute: RouteNames.homePage,
      home: const HomePage(),
    );
  }
}
