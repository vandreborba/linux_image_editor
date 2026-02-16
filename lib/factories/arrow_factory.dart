import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_painter_v2/flutter_painter.dart';
import '../models/arrow_style.dart';

/// Fábrica de setas personalizada com diferentes estilos
class StyledArrowFactory extends ShapeFactory<StyledArrowDrawable> {
  final ArrowStyle style;

  StyledArrowFactory(this.style);

  @override
  StyledArrowDrawable create(Offset position, [Paint? paint]) {
    return StyledArrowDrawable(
      length: 0,
      position: position,
      paint: paint,
      style: style,
    );
  }
}

/// Seta estilizada que pode ser desenhada em diferentes estilos
class StyledArrowDrawable extends ObjectDrawable implements ShapeDrawable {
  @override
  Paint paint;

  final ArrowStyle style;

  final double length;

  StyledArrowDrawable({
    Paint? paint,
    required this.style,
    required this.length,
    required super.position,
    super.rotationAngle = 0,
    super.scale = 1,
    super.assists = const <ObjectDrawableAssist>{},
    super.assistPaints = const <ObjectDrawableAssist, Paint>{},
    super.locked = false,
    super.hidden = false,
  }) : paint = paint ?? ShapeDrawable.defaultPaint;

  @protected
  EdgeInsets get padding {
    final config = style.config;
    final headSize = paint.strokeWidth * config.arrowHeadSizeMultiplier;
    return EdgeInsets.symmetric(
      horizontal: paint.strokeWidth / 2,
      vertical: paint.strokeWidth / 2 + (headSize / 2),
    );
  }

  @override
  void drawObject(Canvas canvas, Size size) {
    final config = style.config;
    final headLength = paint.strokeWidth * config.arrowHeadSizeMultiplier;

    // Para setas abertas, a linha vai até o final; para preenchidas, para antes
    final dx = config.filled
        ? length / 2 * scale - headLength
        : length / 2 * scale;

    final start = position.translate(-length / 2 * scale, 0);
    final end = position.translate(dx, 0);

    // Ângulo de rotação da cabeça (para setas curvas)
    double headRotation = 0.0;

    // Configura paint com extremidades arredondadas para conexões suaves
    final bodyPaint = paint.copyWith(
      strokeCap: StrokeCap.round,
      strokeJoin: StrokeJoin.round,
    );

    // Desenha o corpo da seta
    if ((end - start).dx > 0) {
      if (config.curved && length > 50) {
        headRotation = _drawCurvedArrowBody(canvas, start, end, bodyPaint);
      } else {
        canvas.drawLine(start, end, bodyPaint);
      }
    }

    // Desenha a cabeça da seta
    _drawArrowHead(canvas, config, end, headLength, headRotation);
  }

  double _drawCurvedArrowBody(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint bodyPaint,
  ) {
    final path = Path();
    path.moveTo(start.dx, start.dy);

    // Calcula ponto de controle para criar uma curva suave
    final midX = (start.dx + end.dx) / 2;
    final midY = (start.dy + end.dy) / 2;

    // Offset para criar a curvatura (15% da distância)
    final curvature = (end.dx - start.dx) * 0.15;

    final controlX = midX;
    final controlY = midY - curvature;

    path.quadraticBezierTo(controlX, controlY, end.dx, end.dy);
    canvas.drawPath(path, bodyPaint);

    // Retorna o ângulo da tangente no ponto final
    // Para curva quadrática de Bézier, a tangente no final é o vetor do ponto de controle ao ponto final
    final dx = end.dx - controlX;
    final dy = end.dy - controlY;
    return atan2(dy, dx);
  }

  void _drawArrowHead(
    Canvas canvas,
    ArrowStyleConfig config,
    Offset endPoint,
    double headLength,
    double headRotation,
  ) {
    final headAngleRad = config.arrowHeadAngle * pi / 180;

    if (config.filled) {
      // Seta padrão com cabeça preenchida (triangular)
      // A ponta vai um pouco além do final do corpo
      final tipOffset = _rotatePoint(Offset(headLength, 0), headRotation);
      final tip = endPoint + tipOffset;

      final point1Offset = _rotatePoint(
        Offset(0, -(headLength * sin(headAngleRad))),
        headRotation,
      );
      final point2Offset = _rotatePoint(
        Offset(0, headLength * sin(headAngleRad)),
        headRotation,
      );

      final path = Path();
      path.moveTo(tip.dx, tip.dy);
      path.lineTo(endPoint.dx + point1Offset.dx, endPoint.dy + point1Offset.dy);
      path.lineTo(endPoint.dx + point2Offset.dx, endPoint.dy + point2Offset.dy);
      path.close();

      final headPaint = paint.copyWith(style: PaintingStyle.fill);
      canvas.drawPath(path, headPaint);
    } else {
      // Setas com duas linhas simples saindo da ponta
      // Desenha como um path contínuo para evitar problemas de conexão

      // Calcula os pontos da cabeça com rotação
      final backPoint1Offset = _rotatePoint(
        Offset(-headLength, -(headLength * sin(headAngleRad))),
        headRotation,
      );
      final backPoint2Offset = _rotatePoint(
        Offset(-headLength, headLength * sin(headAngleRad)),
        headRotation,
      );

      final backPoint1 = endPoint + backPoint1Offset;
      final backPoint2 = endPoint + backPoint2Offset;

      // Desenha como um path em forma de V
      final path = Path();
      path.moveTo(backPoint1.dx, backPoint1.dy);
      path.lineTo(endPoint.dx, endPoint.dy);
      path.lineTo(backPoint2.dx, backPoint2.dy);

      // Configura o paint com junções suaves
      final headPaint = paint.copyWith(
        strokeCap: StrokeCap.round,
        strokeJoin: StrokeJoin.round,
      );

      canvas.drawPath(path, headPaint);
    }
  }

  // Função auxiliar para rotacionar um ponto
  Offset _rotatePoint(Offset point, double angle) {
    final cosAngle = cos(angle);
    final sinAngle = sin(angle);
    return Offset(
      point.dx * cosAngle - point.dy * sinAngle,
      point.dx * sinAngle + point.dy * cosAngle,
    );
  }

  @override
  StyledArrowDrawable copyWith({
    bool? hidden,
    Set<ObjectDrawableAssist>? assists,
    Offset? position,
    double? rotation,
    double? scale,
    double? length,
    Paint? paint,
    bool? locked,
    ArrowStyle? style,
  }) {
    return StyledArrowDrawable(
      hidden: hidden ?? this.hidden,
      assists: assists ?? this.assists,
      position: position ?? this.position,
      rotationAngle: rotation ?? rotationAngle,
      scale: scale ?? this.scale,
      length: length ?? this.length,
      paint: paint ?? this.paint,
      locked: locked ?? this.locked,
      style: style ?? this.style,
    );
  }

  @override
  Size getSize({double minWidth = 0.0, double maxWidth = double.infinity}) {
    final config = style.config;
    final headSize = paint.strokeWidth * config.arrowHeadSizeMultiplier;
    return Size(
      length * scale + paint.strokeWidth,
      paint.strokeWidth + headSize,
    );
  }
}
