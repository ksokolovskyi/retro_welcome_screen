import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:retro_welcome_screen/welcome_screen/widgets/widgets.dart';

class Background extends StatefulWidget {
  const Background({
    required this.onEdgeCollision,
    super.key,
  });

  final VoidCallback onEdgeCollision;

  @override
  State<Background> createState() => _BackgroundState();
}

class _BackgroundState extends State<Background>
    with SingleTickerProviderStateMixin {
  late final _frameNotifier = _FrameNotifier();

  late final _delegate = _BackgroundChildLayoutDelegate(
    frameNotifier: _frameNotifier,
    onEdgeCollision: _onEdgeCollision,
  );

  late final _variant = ValueNotifier(LogoVariant.silver);

  var _elapsed = Duration.zero;

  late final Ticker _ticker;

  late final AppLifecycleListener _applicationLifecycleListener;

  @override
  void initState() {
    super.initState();

    _ticker = createTicker((elapsed) {
      final diff = elapsed - _elapsed;

      _frameNotifier.millisecondsElapsed = diff.inMilliseconds;

      _elapsed = elapsed;
    });

    _ticker.start();

    _applicationLifecycleListener = AppLifecycleListener(
      onStateChange: _onStateChanged,
    );
  }

  @override
  void dispose() {
    _frameNotifier.dispose();
    _variant.dispose();
    _applicationLifecycleListener.dispose();

    super.dispose();
  }

  void _onStateChanged(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _ticker.stop();

      case AppLifecycleState.resumed:
        if (_ticker.isActive) {
          return;
        }

        _elapsed = Duration.zero;
        _ticker.start();

      case AppLifecycleState.inactive:
      // ignore.
    }
  }

  Future<void> _onEdgeCollision() async {
    if (!mounted) {
      return;
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _variant.value = _variant.value.next;
      widget.onEdgeCollision();
    });

    HapticFeedback.lightImpact().ignore();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: CustomMultiChildLayout(
        delegate: _delegate,
        children: [
          LayoutId(
            id: Logo,
            child: ValueListenableBuilder(
              valueListenable: _variant,
              builder: (context, variant, _) {
                return Logo(variant: variant);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FrameNotifier extends ChangeNotifier {
  int _millisecondsElapsed = 0;

  /// The amount of milliseconds elapsed from the previous frame.
  int get millisecondsElapsed => _millisecondsElapsed;

  set millisecondsElapsed(int value) {
    _millisecondsElapsed = value;
    notifyListeners();
  }
}

class _BackgroundChildLayoutDelegate extends MultiChildLayoutDelegate {
  _BackgroundChildLayoutDelegate({
    required this.frameNotifier,
    required this.onEdgeCollision,
  }) : super(relayout: frameNotifier);

  final _FrameNotifier frameNotifier;

  final VoidCallback onEdgeCollision;

  Offset? _childTopLeft;

  /// The amount of pixels to move the child every 16 milliseconds.
  static const _dt = 3.0;

  var _dx = _dt;
  var _dy = _dt;

  @override
  void performLayout(Size size) {
    var childSide = size.shortestSide * 0.24;
    childSide = math.min(childSide, 90);

    final childSize = layoutChild(
      Logo,
      BoxConstraints.tight(Size.square(childSide)),
    );

    // This check is needed as on iOS Flutter has zero size first frame in the
    // release mode which has to be ignored in our case.
    // Details: https://github.com/flutter/flutter/issues/149974#issuecomment-2166168911.
    if (size == Size.zero) {
      return;
    }

    if (_childTopLeft == null) {
      final top = size.height * 0.235;
      final left = size.width / 2 - childSide / 2;

      _childTopLeft = Offset(left, top);
    }

    assert(
      _childTopLeft != null,
      '_childTopLeft has to be initialized in this step',
    );

    final childRect = _childTopLeft! & childSize;
    final factor = frameNotifier.millisecondsElapsed / 16;

    final translatedChildRect = childRect.translate(_dx * factor, _dy * factor);

    var hasCollision = false;

    if (translatedChildRect.left < 0) {
      _dx = _dt;
      hasCollision = true;
    } else if (translatedChildRect.right > size.width) {
      _dx = -_dt;
      hasCollision = true;
    }

    if (translatedChildRect.top < 0) {
      _dy = _dt;
      hasCollision = true;
    } else if (translatedChildRect.bottom > size.height) {
      _dy = -_dt;
      hasCollision = true;
    }

    if (hasCollision) {
      onEdgeCollision();
    }

    _childTopLeft = translatedChildRect.topLeft;

    positionChild(Logo, _childTopLeft!);
  }

  @override
  bool shouldRelayout(_BackgroundChildLayoutDelegate oldDelegate) {
    return false;
  }
}
