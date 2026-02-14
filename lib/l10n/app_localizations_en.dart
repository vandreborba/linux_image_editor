// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Linux Image Editor';

  @override
  String get openImageTooltip => 'Open image (Ctrl+O)';

  @override
  String get pasteFromClipboardTooltip => 'Paste from clipboard (Ctrl+V)';

  @override
  String get saveTooltip => 'Save (Ctrl+S)';

  @override
  String get saveAsTooltip => 'Save As (Ctrl+Shift+S)';

  @override
  String get copyButtonLabel => 'Copy';

  @override
  String get undoTooltip => 'Undo (Ctrl+Z)';

  @override
  String get closeTooltip => 'Close';

  @override
  String get noImageLoadedTitle => 'No image loaded';

  @override
  String get emptyStateHintLine1 =>
      'Copy a screenshot and it will appear here automatically';

  @override
  String get emptyStateHintLine2 =>
      'Or open an image or pass a file via command line';

  @override
  String get openImageButtonLabel => 'Open Image';

  @override
  String get pasteButtonLabel => 'Paste';

  @override
  String get zoomInTooltip => 'Zoom in';

  @override
  String get zoomOutTooltip => 'Zoom out';

  @override
  String get zoomResetTooltip => 'Reset zoom (100%)';

  @override
  String get cancelButtonLabel => 'Cancel';

  @override
  String get applyCropButtonLabel => 'Apply Crop';

  @override
  String get saveImageDialogTitle => 'Save image';

  @override
  String get defaultEditedFileName => 'screenshot_edited.png';

  @override
  String get noImageToSave => 'No image to save';

  @override
  String get imageSavedSuccess => 'Image saved successfully!';

  @override
  String get imageCopiedSuccess => 'Image copied to clipboard!';

  @override
  String errorLoadImage(Object error) {
    return 'Failed to load image: $error';
  }

  @override
  String errorOpenImage(Object error) {
    return 'Failed to open image: $error';
  }

  @override
  String errorSaveImage(Object error) {
    return 'Failed to save image: $error';
  }

  @override
  String errorCaptureImage(Object error) {
    return 'Failed to capture image: $error';
  }

  @override
  String get errorCaptureImageGeneric => 'Could not capture the image';

  @override
  String errorCopyImage(Object error) {
    return 'Failed to copy image: $error';
  }

  @override
  String get toolSelectTooltip => 'Select';

  @override
  String get toolBrushTooltip => 'Brush';

  @override
  String get toolHighlighterTooltip => 'Highlighter';

  @override
  String get toolArrowTooltip => 'Arrow';

  @override
  String get toolRectangleTooltip => 'Rectangle';

  @override
  String get toolTextTooltip => 'Text';

  @override
  String get toolEraserTooltip => 'Eraser';

  @override
  String get cropTooltip => 'Crop';

  @override
  String get colorTooltip => 'Color';

  @override
  String strokeWidthTooltip(Object value) {
    return 'Stroke width: ${value}px';
  }

  @override
  String get strokeWidthTitle => 'Stroke width';

  @override
  String get okButtonLabel => 'OK';
}
