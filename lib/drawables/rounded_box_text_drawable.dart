import 'package:flutter/material.dart';
import 'package:flutter_painter_v2/flutter_painter.dart';

/// Drawable que desenha texto com uma caixa arredondada ao redor
class RoundedBoxTextDrawable extends ObjectDrawable {
  /// O texto a ser desenhado
  final String text;

  /// O estilo do texto
  final TextStyle style;

  /// A cor de fundo da caixa
  final Color backgroundColor;

  /// O padding ao redor do texto
  final EdgeInsets padding;

  /// O raio dos cantos arredondados
  final double borderRadius;

  /// A direção do texto
  final TextDirection direction;

  /// TextPainter para renderizar o texto
  final TextPainter textPainter;

  /// Cria um [RoundedBoxTextDrawable] que desenha texto com caixa arredondada
  RoundedBoxTextDrawable({
    required this.text,
    required super.position,
    double rotation = 0,
    super.scale = 1,
    required this.backgroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.borderRadius = 12.0,
    this.style = const TextStyle(
      fontSize: 24,
      color: Colors.white,
      fontWeight: FontWeight.w500,
    ),
    this.direction = TextDirection.ltr,
    super.locked = false,
    super.hidden = false,
    super.assists = const <ObjectDrawableAssist>{},
  }) : textPainter = TextPainter(
         text: TextSpan(text: text, style: style),
         textAlign: TextAlign.center,
         textScaler: TextScaler.linear(scale),
         textDirection: direction,
       ),
       super(rotationAngle: rotation);

  @override
  void drawObject(Canvas canvas, Size size) {
    // Renderiza o texto para obter suas dimensões
    textPainter.layout(maxWidth: size.width * scale);

    final textWidth = textPainter.width;
    final textHeight = textPainter.height;

    // Calcula as dimensões da caixa incluindo o padding
    final boxWidth = textWidth + padding.left + padding.right;
    final boxHeight = textHeight + padding.top + padding.bottom;

    // Calcula a posição da caixa (centralizada na posição do drawable)
    final boxRect = Rect.fromCenter(
      center: position,
      width: boxWidth,
      height: boxHeight,
    );

    // Desenha a caixa arredondada
    final boxPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final rRect = RRect.fromRectAndRadius(
      boxRect,
      Radius.circular(borderRadius),
    );

    canvas.drawRRect(rRect, boxPaint);

    // Calcula a posição do texto (centralizado dentro da caixa)
    final textOffset = Offset(
      position.dx - textWidth / 2,
      position.dy - textHeight / 2,
    );

    // Desenha o texto
    textPainter.paint(canvas, textOffset);
  }

  @override
  RoundedBoxTextDrawable copyWith({
    bool? hidden,
    Set<ObjectDrawableAssist>? assists,
    String? text,
    Offset? position,
    double? rotation,
    double? scale,
    TextStyle? style,
    bool? locked,
    TextDirection? direction,
    Color? backgroundColor,
    EdgeInsets? padding,
    double? borderRadius,
  }) {
    return RoundedBoxTextDrawable(
      text: text ?? this.text,
      position: position ?? this.position,
      rotation: rotation ?? rotationAngle,
      scale: scale ?? this.scale,
      style: style ?? this.style,
      direction: direction ?? this.direction,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      padding: padding ?? this.padding,
      borderRadius: borderRadius ?? this.borderRadius,
      assists: assists ?? this.assists,
      hidden: hidden ?? this.hidden,
      locked: locked ?? this.locked,
    );
  }

  @override
  Size getSize({double minWidth = 0.0, double maxWidth = double.infinity}) {
    // Renderiza o texto para obter suas dimensões
    textPainter.layout(minWidth: minWidth, maxWidth: maxWidth * scale);

    // Retorna o tamanho incluindo o padding
    return Size(
      textPainter.width + padding.left + padding.right,
      textPainter.height + padding.top + padding.bottom,
    );
  }
}
