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
  String get clearAllTooltip => 'Clear all changes';

  @override
  String get previousFileTooltip => 'Previous file';

  @override
  String get nextFileTooltip => 'Next file';

  @override
  String previousFileWithName(Object fileName) {
    return 'Previous: $fileName';
  }

  @override
  String nextFileWithName(Object fileName) {
    return 'Next: $fileName';
  }

  @override
  String get fileNavigationTooltip => 'Go to file';

  @override
  String get sortByTooltip => 'Sort by';

  @override
  String get sortByName => 'Name';

  @override
  String get sortByDate => 'Date';

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

  @override
  String get textDialogTitle => 'Add Text';

  @override
  String get textInputLabel => 'Text';

  @override
  String get textInputHint => 'Type your text here...';

  @override
  String get fontSizeLabel => 'Font size:';

  @override
  String get textStyleLabel => 'Text style';

  @override
  String get textPreviewLabel => 'Preview';

  @override
  String get textPreviewPlaceholder => 'Sample text';

  @override
  String get resizeTooltip => 'Resize';

  @override
  String get resizeDialogTitle => 'Resize Image';

  @override
  String currentSizeLabel(Object width, Object height) {
    return 'Current: $width x $height px';
  }

  @override
  String get pixelsLabel => 'Pixels';

  @override
  String get percentageLabel => 'Percentage';

  @override
  String get percentageHelperText => 'e.g., 50 for half size, 200 for double';

  @override
  String get widthLabel => 'Width';

  @override
  String get heightLabel => 'Height';

  @override
  String get maintainAspectRatioLabel => 'Maintain aspect ratio';

  @override
  String newSizeLabel(Object width, Object height) {
    return 'New size: $width x $height px';
  }

  @override
  String get applyButtonLabel => 'Apply';

  @override
  String get errorResizeImage => 'Failed to resize image';

  @override
  String get imageResizedSuccess => 'Image resized successfully!';

  @override
  String get aspectRatioFree => 'Free';

  @override
  String get fixedSizeLabel => 'Fixed Size (px)';

  @override
  String get fixedSizeDialogTitle => 'Fixed Size Crop';

  @override
  String get fixedSizeDialogDescription =>
      'Enter dimensions in pixels. The crop area will be fixed and you can only reposition it.';
}
