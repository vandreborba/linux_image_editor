import 'package:linux_image_editor/l10n/app_localizations.dart';

enum ArrowStyle { standard, wide, curved }

extension ArrowStyleExtension on ArrowStyle {
  String displayName(AppLocalizations l10n) {
    switch (this) {
      case ArrowStyle.standard:
        return l10n.arrowStyleStandard;
      case ArrowStyle.wide:
        return l10n.arrowStyleWide;
      case ArrowStyle.curved:
        return l10n.arrowStyleCurved;
    }
  }

  String description(AppLocalizations l10n) {
    switch (this) {
      case ArrowStyle.standard:
        return l10n.arrowStyleStandardDesc;
      case ArrowStyle.wide:
        return l10n.arrowStyleWideDesc;
      case ArrowStyle.curved:
        return l10n.arrowStyleCurvedDesc;
    }
  }

  ArrowStyleConfig get config {
    switch (this) {
      case ArrowStyle.standard:
        return const ArrowStyleConfig(
          arrowHeadSizeMultiplier: 3.0,
          arrowHeadAngle: 25.0,
          curved: false,
          filled: true,
        );
      case ArrowStyle.wide:
        return const ArrowStyleConfig(
          arrowHeadSizeMultiplier: 3.5,
          arrowHeadAngle: 50.0,
          curved: false,
          filled: false,
        );
      case ArrowStyle.curved:
        return const ArrowStyleConfig(
          arrowHeadSizeMultiplier: 3.2,
          arrowHeadAngle: 28.0,
          curved: true,
          filled: false,
        );
    }
  }
}

class ArrowStyleConfig {
  final double arrowHeadSizeMultiplier;
  final double arrowHeadAngle;
  final bool curved;
  final bool filled;

  const ArrowStyleConfig({
    required this.arrowHeadSizeMultiplier,
    required this.arrowHeadAngle,
    required this.curved,
    required this.filled,
  });
}
