import 'package:flutter/material.dart';
import 'package:retro_welcome_screen/welcome_screen/widgets/widgets.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _subtitleVariant = ValueNotifier<ForegroundSubtitleVariant>(
    ForegroundSubtitleVariant.addFreeSocial,
  );

  @override
  void dispose() {
    _subtitleVariant.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Background(
              onEdgeCollision: () {
                _subtitleVariant.value = _subtitleVariant.value.next;
              },
            ),
          ),
          Positioned.fill(
            child: Foreground(
              subtitleVariant: _subtitleVariant,
            ),
          ),
        ],
      ),
    );
  }
}
