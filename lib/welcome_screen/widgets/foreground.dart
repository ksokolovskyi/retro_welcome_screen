import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:vector_graphics/vector_graphics.dart';

enum ForegroundSubtitleVariant {
  addFreeSocial,
  recapYourLife,
  weekToWeek,
  friendsOnly;

  ForegroundSubtitleVariant get next {
    final nextIndex = (index + 1) % values.length;
    return values[nextIndex];
  }

  String get _text => switch (this) {
        ForegroundSubtitleVariant.addFreeSocial => 'Ad Free Social',
        ForegroundSubtitleVariant.recapYourLife => 'Recap Your Life',
        ForegroundSubtitleVariant.weekToWeek => 'Week to Week',
        ForegroundSubtitleVariant.friendsOnly => 'Friends Only',
      };
}

class Foreground extends StatelessWidget {
  const Foreground({
    required this.subtitleVariant,
    super.key,
  });

  final ValueNotifier<ForegroundSubtitleVariant> subtitleVariant;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomMultiChildLayout(
            delegate: _TitleAndSubtitleLayoutDelegate(),
            children: [
              LayoutId(
                id: _Title,
                child: const _Title(),
              ),
              LayoutId(
                id: _Subtitle,
                child: RepaintBoundary(
                  child: ValueListenableBuilder(
                    valueListenable: subtitleVariant,
                    builder: (context, variant, _) {
                      return _Subtitle(variant: variant);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const Positioned(
          right: 0,
          left: 0,
          bottom: 0,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 4,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Button(),
                  SizedBox(height: 14),
                  _SupportText(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TitleAndSubtitleLayoutDelegate extends MultiChildLayoutDelegate {
  @override
  void performLayout(Size size) {
    final titleSize = layoutChild(
      _Title,
      BoxConstraints.loose(size),
    );
    final titleRect = Offset(
          size.width / 2 - titleSize.width / 2,
          size.height * 0.38,
        ) &
        titleSize;

    positionChild(_Title, titleRect.topLeft);

    final subtitleSize = layoutChild(
      _Subtitle,
      BoxConstraints.loose(size),
    );
    final subtitleRect = Offset(
          size.width / 2 - subtitleSize.width / 2,
          titleRect.bottom + 16,
        ) &
        subtitleSize;

    positionChild(_Subtitle, subtitleRect.topLeft);
  }

  @override
  bool shouldRelayout(_TitleAndSubtitleLayoutDelegate oldDelegate) {
    return false;
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    return const VectorGraphic(
      loader: AssetBytesLoader('assets/images/logo.svg'),
      height: 52,
    );
  }
}

class _Subtitle extends StatelessWidget {
  const _Subtitle({
    required this.variant,
  });

  final ForegroundSubtitleVariant variant;

  @override
  Widget build(BuildContext context) {
    return Text(
      variant._text,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.normal,
        fontSize: 28,
        height: 1,
        letterSpacing: -0.42,
        color: Color(0xFF7F7F7F),
      ),
      textAlign: TextAlign.justify,
    );
  }
}

class _Button extends StatelessWidget {
  const _Button();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: const DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(100)),
          color: Colors.black,
        ),
        child: Padding(
          padding: EdgeInsets.all(18),
          child: Text(
            "Let's go",
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              height: 24 / 18,
              letterSpacing: 0,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _SupportText extends StatefulWidget {
  const _SupportText();

  @override
  State<_SupportText> createState() => _SupportTextState();
}

class _SupportTextState extends State<_SupportText> {
  late final _termsGestureRecognizer = TapGestureRecognizer()
    ..onTap = _launchTerms;

  late final _privacyPolicyGestureRecognizer = TapGestureRecognizer()
    ..onTap = _launchPrivacyPolicy;

  late final _whatIsRetroGestureRecognizer = TapGestureRecognizer()
    ..onTap = _launchWhatIsRetro;

  @override
  void dispose() {
    _termsGestureRecognizer.dispose();
    super.dispose();
  }

  void _launchTerms() {}

  void _launchPrivacyPolicy() {}

  void _launchWhatIsRetro() {}

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.normal,
      fontSize: 14,
      height: 23 / 14,
      letterSpacing: -0.28,
      color: Colors.black,
    );
    const linkStyle = TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.w600,
      fontSize: 15,
      height: 23 / 15,
      letterSpacing: -0.45,
      color: Colors.black,
      decoration: TextDecoration.underline,
    );

    return Text.rich(
      TextSpan(
        text: 'By continuing you agree to our\n',
        children: [
          TextSpan(
            text: 'Terms',
            style: linkStyle,
            recognizer: _termsGestureRecognizer,
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: linkStyle,
            recognizer: _privacyPolicyGestureRecognizer,
          ),
          const TextSpan(text: '. '),
          TextSpan(
            text: "What's Retro?",
            style: linkStyle,
            recognizer: _whatIsRetroGestureRecognizer,
          ),
        ],
      ),
      style: textStyle,
      textAlign: TextAlign.center,
    );
  }
}
