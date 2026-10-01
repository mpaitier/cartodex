import 'package:flutter/widgets.dart';

/// Détecte un pincement à deux doigts sur [child], sans jamais
/// intercepter les gestes de celui-ci (défilement de la grille,
/// swipe du `PageView`, tap, double-tap).
///
/// S'appuie sur un `Listener` (événements bruts, hors de l'arène de
/// gestes) plutôt que sur `GestureDetector.onScale*` : un
/// `ScaleGestureRecognizer` entrerait en concurrence avec les
/// recognizers de défilement et de tap des enfants.
///
/// Un pincement déclenche au plus un callback, une fois le seuil
/// d'écartement franchi ; il faut relever les doigts pour en
/// déclencher un autre.
/// - [onPinchIn] : les doigts se rapprochent ;
/// - [onPinchOut] : les doigts s'écartent.
class PinchGestureDetector extends StatefulWidget {
  const PinchGestureDetector({
    required this.child,
    this.onPinchIn,
    this.onPinchOut,
    super.key,
  });

  final Widget child;
  final VoidCallback? onPinchIn;
  final VoidCallback? onPinchOut;

  /// Rapport entre la distance courante et la distance initiale des
  /// deux doigts au-delà (resp. en deçà) duquel le pincement compte.
  static const double _spreadThreshold = 1.25;
  static const double _pinchThreshold = 0.8;

  @override
  State<PinchGestureDetector> createState() => _PinchGestureDetectorState();
}

class _PinchGestureDetectorState extends State<PinchGestureDetector> {
  final Map<int, Offset> _pointers = {};
  double? _startDistance;
  bool _triggered = false;

  double get _distance {
    final positions = _pointers.values.toList();
    return (positions[0] - positions[1]).distance;
  }

  void _onPointerDown(PointerDownEvent event) {
    _pointers[event.pointer] = event.position;
    if (_pointers.length == 2) {
      _startDistance = _distance;
      _triggered = false;
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_pointers.containsKey(event.pointer)) return;
    _pointers[event.pointer] = event.position;
    if (_pointers.length != 2 || _triggered) return;

    final start = _startDistance;
    if (start == null || start == 0) return;
    final ratio = _distance / start;
    if (ratio >= PinchGestureDetector._spreadThreshold) {
      _triggered = true;
      widget.onPinchOut?.call();
    } else if (ratio <= PinchGestureDetector._pinchThreshold) {
      _triggered = true;
      widget.onPinchIn?.call();
    }
  }

  void _onPointerEnd(PointerEvent event) {
    _pointers.remove(event.pointer);
    if (_pointers.length < 2) {
      _startDistance = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerEnd,
      onPointerCancel: _onPointerEnd,
      child: widget.child,
    );
  }
}