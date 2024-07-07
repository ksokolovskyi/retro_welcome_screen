import 'package:flutter/material.dart';
import 'package:retro_welcome_screen/welcome_screen/welcome_screen.dart';

Future<void> main() async {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WelcomeScreen(),
    );
  }
}
