import 'package:flutter/material.dart';

enum LogoVariant {
  silver,
  red,
  colorfulGlossy,
  colorfulMatte;

  LogoVariant get next {
    final nextIndex = (index + 1) % values.length;
    return values[nextIndex];
  }

  String get _asset => switch (this) {
        LogoVariant.silver => 'assets/images/1.png',
        LogoVariant.red => 'assets/images/2.png',
        LogoVariant.colorfulGlossy => 'assets/images/3.png',
        LogoVariant.colorfulMatte => 'assets/images/4.png',
      };
}

class Logo extends StatefulWidget {
  const Logo({
    required this.variant,
    super.key,
  });

  final LogoVariant variant;

  @override
  State<Logo> createState() => _LogoState();
}

class _LogoState extends State<Logo> {
  var _cached = false;

  late double devicePixelRatio;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    devicePixelRatio = MediaQuery.devicePixelRatioOf(context);

    _requestCachingIfNeeded();
  }

  void _requestCachingIfNeeded() {
    if (_cached) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _cache());
  }

  Future<void> _cache() async {
    if (!mounted) {
      return;
    }

    final size = (context.findRenderObject()! as RenderBox).size;

    // This check is needed as on iOS Flutter has zero size first frame in the
    // release mode which has to be ignored in our case.
    // Details: https://github.com/flutter/flutter/issues/149974#issuecomment-2166168911.
    if (size == Size.zero) {
      _requestCachingIfNeeded();
      return;
    }

    final side = size.width;
    final cacheSide = (side * devicePixelRatio).round();

    for (final variant in LogoVariant.values) {
      precacheImage(
        ResizeImage.resizeIfNeeded(
          cacheSide,
          cacheSide,
          AssetImage(variant._asset),
        ),
        context,
        size: size,
      ).ignore();
    }

    _cached = true;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final side = constraints.biggest.width;
          final cacheSide = (side * devicePixelRatio).round();

          return Image.asset(
            widget.variant._asset,
            width: side,
            height: side,
            cacheHeight: cacheSide,
            cacheWidth: cacheSide,
          );
        },
      ),
    );
  }
}
