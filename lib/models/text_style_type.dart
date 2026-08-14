import 'package:flutter/material.dart';
import 'package:linux_image_editor/l10n/app_localizations.dart';

enum TextStyleType { plain, shadow, roundedBox }

extension TextStyleTypeExtension on TextStyleType {
  String displayName(AppLocalizations l10n) {
    switch (this) {
      case TextStyleType.plain:
        return l10n.textStylePlain;
      case TextStyleType.shadow:
        return l10n.textStyleShadow;
      case TextStyleType.roundedBox:
        return l10n.textStyleRoundedBox;
    }
  }

  String description(AppLocalizations l10n) {
    switch (this) {
      case TextStyleType.plain:
        return l10n.textStylePlainDesc;
      case TextStyleType.shadow:
        return l10n.textStyleShadowDesc;
      case TextStyleType.roundedBox:
        return l10n.textStyleRoundedBoxDesc;
    }
  }

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
