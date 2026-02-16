enum ArrowStyle { standard, wide, curved }

extension ArrowStyleExtension on ArrowStyle {
  String get displayName {
    switch (this) {
      case ArrowStyle.standard:
        return 'Padrão';
      case ArrowStyle.wide:
        return 'Aberta';
      case ArrowStyle.curved:
        return 'Curva';
    }
  }

  String get description {
    switch (this) {
      case ArrowStyle.standard:
        return 'Seta com ponta fechada';
      case ArrowStyle.wide:
        return 'Seta com ponta mais aberta';
      case ArrowStyle.curved:
        return 'Seta curvada';
    }
  }

  // Configurações visuais para cada estilo
  ArrowStyleConfig get config {
    switch (this) {
      case ArrowStyle.standard:
        return ArrowStyleConfig(
          arrowHeadSizeMultiplier: 3.0,
          arrowHeadAngle: 25.0,
          curved: false,
          filled: true,
        );
      case ArrowStyle.wide:
        return ArrowStyleConfig(
          arrowHeadSizeMultiplier: 3.5,
          arrowHeadAngle: 50.0,
          curved: false,
          filled: false,
        );
      case ArrowStyle.curved:
        return ArrowStyleConfig(
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
