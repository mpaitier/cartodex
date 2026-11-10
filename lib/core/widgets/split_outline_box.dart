import 'package:flutter/material.dart';

/// Cadre arrondi dont chaque moitié a sa couleur : moitié gauche
/// [leftColor], moitié droite [rightColor].
///
/// Reprend la convention des tuiles de l'accueil (gauche pour les
/// losanges, droite pour les étoiles), mais sans notion de progression :
/// chaque moitié est simplement allumée ou non. Utilisé pour signaler,
/// côté losanges ou côté étoiles, qu'une extension est complète.
///
/// La bordure est dessinée par-dessus [child], qui doit prévoir une
/// marge intérieure d'au moins [strokeWidth].
class SplitOutlineBox extends StatelessWidget {
  const SplitOutlineBox({
    required this.leftColor,
    required this.rightColor,
    required this.child,
    this.cornerRadius = 6,
    this.strokeWidth = 2,
    super.key,
  });

  final Color leftColor;
  final Color rightColor;
  final double cornerRadius;
  final double strokeWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _SplitOutlinePainter(
        leftColor: leftColor,
        rightColor: rightColor,
        cornerRadius: cornerRadius,
        strokeWidth: strokeWidth,
      ),
      child: child,
    );
  }
}

class _SplitOutlinePainter extends CustomPainter {
  const _SplitOutlinePainter({
    required this.leftColor,
    required this.rightColor,
    required this.cornerRadius,
    required this.strokeWidth,
  });

  final Color leftColor;
  final Color rightColor;
  final double cornerRadius;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    // Trait centré sur le contour : on le décale d'une demi-épaisseur
    // pour qu'il reste entièrement dans la zone du widget.
    final inset = strokeWidth / 2;
    final outline = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        inset,
        inset,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(cornerRadius),
    );
    final half = size.width / 2;
    _paintHalf(
      canvas,
      outline,
      Rect.fromLTWH(0, 0, half, size.height),
      leftColor,
    );
    _paintHalf(
      canvas,
      outline,
      Rect.fromLTWH(half, 0, size.width - half, size.height),
      rightColor,
    );
  }

  void _paintHalf(Canvas canvas, RRect outline, Rect clip, Color color) {
    canvas
      ..save()
      ..clipRect(clip)
      ..drawRRect(
        outline,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_SplitOutlinePainter oldDelegate) =>
      oldDelegate.leftColor != leftColor ||
      oldDelegate.rightColor != rightColor ||
      oldDelegate.cornerRadius != cornerRadius ||
      oldDelegate.strokeWidth != strokeWidth;
}
