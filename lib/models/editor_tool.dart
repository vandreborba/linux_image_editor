enum EditorTool { none, brush, highlighter, arrow, rectangle, text, eraser }

extension EditorToolExtension on EditorTool {
  String get displayName {
    switch (this) {
      case EditorTool.none:
        return 'Select';
      case EditorTool.brush:
        return 'Pincel';
      case EditorTool.highlighter:
        return 'Highlighter';
      case EditorTool.arrow:
        return 'Seta';
      case EditorTool.rectangle:
        return 'Retângulo';
      case EditorTool.text:
        return 'Texto';
      case EditorTool.eraser:
        return 'Borracha';
    }
  }
}
