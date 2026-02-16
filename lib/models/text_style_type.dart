import 'package:flutter/material.dart';

enum TextStyleType { plain, shadow, roundedBox }

extension TextStyleTypeExtension on TextStyleType {
  String get displayName {
    switch (this) {
      case TextStyleType.plain:
        return 'Simples';
      case TextStyleType.shadow:
        return 'Com Sombra';
      case TextStyleType.roundedBox:
        return 'Caixa Arredondada';
    }
  }

  String get description {
    switch (this) {
      case TextStyleType.plain:
        return 'Texto simples sem efeitos';
      case TextStyleType.shadow:
        return 'Texto com sombra para destaque';
      case TextStyleType.roundedBox:
        return 'Texto com fundo arredondado para contraste';
    }
  }

  // Configurações visuais para cada estilo
  TextStyleConfig get config {
    switch (this) {
      case TextStyleType.plain:
        return const TextStyleConfig(hasShadow: false, hasBackground: false);
      case TextStyleType.shadow:
        return const TextStyleConfig(
          hasShadow: true,
          hasBackground: false,
          shadowOffset: Offset(2, 2),
          shadowBlurRadius: 4.0,
          shadowColor: Colors.black54,
        );
      case TextStyleType.roundedBox:
        return const TextStyleConfig(
          hasShadow: false,
          hasBackground: true,
          backgroundPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          borderRadius: 12.0,
        );
    }
  }
}

class TextStyleConfig {
  final bool hasShadow;
  final bool hasBackground;
  final Offset shadowOffset;
  final double shadowBlurRadius;
  final Color shadowColor;
  final EdgeInsets backgroundPadding;
  final double borderRadius;

  const TextStyleConfig({
    required this.hasShadow,
    required this.hasBackground,
    this.shadowOffset = Offset.zero,
    this.shadowBlurRadius = 0.0,
    this.shadowColor = Colors.transparent,
    this.backgroundPadding = EdgeInsets.zero,
    this.borderRadius = 0.0,
  });
}

class TextConfig {
  final String text;
  final TextStyleType styleType;
  final double fontSize;
  final Color color;

  const TextConfig({
    required this.text,
    required this.styleType,
    required this.fontSize,
    required this.color,
  });

  TextStyle getTextStyle() {
    final config = styleType.config;
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      shadows: config.hasShadow
          ? [
              Shadow(
                offset: config.shadowOffset,
                blurRadius: config.shadowBlurRadius,
                color: config.shadowColor,
              ),
            ]
          : null,
    );
  }
}
