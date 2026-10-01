import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../domain/entities/set_progress.dart';

/// Dessine la bordure d'une tuile de set, coupée en deux moitiés.
///
/// La moitié gauche suit les cartes losange ([SetProgress.base]), la
/// moitié droite les cartes alternatives ([SetProgress.alternative]).
/// Chaque moitié part du haut au centre et descend vers le bas :
/// à 100 %, les deux se rejoignent en bas au milieu.
///
/// Sur une moitié, le segment du compte principal vient en premier,
/// le segment des comptes secondaires prolonge juste après. Il passe
/// au vert seulement si le principal, à lui seul, a tout le groupe.
class SetProgressBorderPainter extends CustomPainter {
  const SetProgressBorderPainter({
    required this.progress,
    required this.trackColor,
    required this.primaryColor,
    required this.secondaryColor,
    required this.completeColor,
    required this.cornerRadius,
    required this.strokeWidth,
  });

  /// `null` quand aucune progression n'est connue : seul le fond de
  /// la bordure est dessiné.
  final SetProgress? progress;

  final Color trackColor;
  final Color primaryColor;
  final Color secondaryColor;
  final Color completeColor;

  /// Rayon des coins de la tuile, bord extérieur.
  final double cornerRadius;

  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    // Le trait est centré sur un rectangle rentré de la moitié de son
    // épaisseur, pour que la bordure reste entièrement dans la tuile.
    final inset = strokeWidth / 2;
    final bounds = Rect.fromLTRB(
      inset,
      inset,
      size.width - inset,
      size.height - inset,
    );
    final radius = cornerRadius - inset;

    _paintHalf(canvas, _leftHalfPath(bounds, radius), progress?.base);
    _paintHalf(canvas, _rightHalfPath(bounds, radius), progress?.alternative);
  }

  /// Du haut au centre, vers la gauche puis le long du côté gauche,
  /// jusqu'au bas au centre.
  Path _leftHalfPath(Rect b, double r) {
    return Path()
      ..moveTo(b.center.dx, b.top)
      ..lineTo(b.left + r, b.top)
      ..arcTo(
        Rect.fromLTWH(b.left, b.top, 2 * r, 2 * r),
        -math.pi / 2,
        -math.pi / 2,
        false,
      )
      ..lineTo(b.left, b.bottom - r)
      ..arcTo(
        Rect.fromLTWH(b.left, b.bottom - 2 * r, 2 * r, 2 * r),
        math.pi,
        -math.pi / 2,
        false,
      )
      ..lineTo(b.center.dx, b.bottom);
  }

  /// Symétrique de [_leftHalfPath], côté droit.
  Path _rightHalfPath(Rect b, double r) {
    return Path()
      ..moveTo(b.center.dx, b.top)
      ..lineTo(b.right - r, b.top)
      ..arcTo(
        Rect.fromLTWH(b.right - 2 * r, b.top, 2 * r, 2 * r),
        -math.pi / 2,
        math.pi / 2,
        false,
      )
      ..lineTo(b.right, b.bottom - r)
      ..arcTo(
        Rect.fromLTWH(b.right - 2 * r, b.bottom - 2 * r, 2 * r, 2 * r),
        0,
        math.pi / 2,
        false,
      )
      ..lineTo(b.center.dx, b.bottom);
  }

  void _paintHalf(Canvas canvas, Path path, RarityGroupProgress? group) {
    canvas.drawPath(path, _strokePaint(trackColor));
    if (group == null || group.isEmpty) return;

    final metric = path.computeMetrics().first;
    final primaryEnd = metric.length * group.primaryRatio.clamp(0.0, 1.0);
    final secondaryEnd = metric.length *
        (group.primaryRatio + group.secondaryExtraRatio).clamp(0.0, 1.0);

    if (secondaryEnd > primaryEnd) {
      canvas.drawPath(
        metric.extractPath(primaryEnd, secondaryEnd),
        _strokePaint(secondaryColor),
      );
    }
    if (primaryEnd > 0) {
      canvas.drawPath(
        metric.extractPath(0, primaryEnd),
        _strokePaint(group.isPrimaryComplete ? completeColor : primaryColor),
      );
    }
  }

  Paint _strokePaint(Color color) {
    return Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt
      ..isAntiAlias = true
      ..color = color;
  }

  @override
  bool shouldRepaint(SetProgressBorderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.completeColor != completeColor ||
        oldDelegate.cornerRadius != cornerRadius ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}