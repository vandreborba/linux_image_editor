import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Linux Image Editor'**
  String get appTitle;

  /// No description provided for @openImageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Open image (Ctrl+O)'**
  String get openImageTooltip;

  /// No description provided for @pasteFromClipboardTooltip.
  ///
  /// In en, this message translates to:
  /// **'Paste from clipboard (Ctrl+V)'**
  String get pasteFromClipboardTooltip;

  /// No description provided for @saveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save (Ctrl+S)'**
  String get saveTooltip;

  /// No description provided for @saveAsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save As (Ctrl+Shift+S)'**
  String get saveAsTooltip;

  /// No description provided for @copyButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyButtonLabel;

  /// No description provided for @undoTooltip.
  ///
  /// In en, this message translates to:
  /// **'Undo (Ctrl+Z)'**
  String get undoTooltip;

  /// No description provided for @closeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeTooltip;

  /// No description provided for @noImageLoadedTitle.
  ///
  /// In en, this message translates to:
  /// **'No image loaded'**
  String get noImageLoadedTitle;

  /// No description provided for @emptyStateHintLine1.
  ///
  /// In en, this message translates to:
  /// **'Copy a screenshot and it will appear here automatically'**
  String get emptyStateHintLine1;

  /// No description provided for @emptyStateHintLine2.
  ///
  /// In en, this message translates to:
  /// **'Or open an image or pass a file via command line'**
  String get emptyStateHintLine2;

  /// No description provided for @openImageButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Open Image'**
  String get openImageButtonLabel;

  /// No description provided for @pasteButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get pasteButtonLabel;

  /// No description provided for @zoomInTooltip.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get zoomInTooltip;

  /// No description provided for @zoomOutTooltip.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get zoomOutTooltip;

  /// No description provided for @zoomResetTooltip.
  ///
  /// In en, this message translates to:
  /// **'Reset zoom (100%)'**
  String get zoomResetTooltip;

  /// No description provided for @cancelButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButtonLabel;

  /// No description provided for @applyCropButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Apply Crop'**
  String get applyCropButtonLabel;

  /// No description provided for @saveImageDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Save image'**
  String get saveImageDialogTitle;

  /// No description provided for @defaultEditedFileName.
  ///
  /// In en, this message translates to:
  /// **'screenshot_edited.png'**
  String get defaultEditedFileName;

  /// No description provided for @noImageToSave.
  ///
  /// In en, this message translates to:
  /// **'No image to save'**
  String get noImageToSave;

  /// No description provided for @imageSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Image saved successfully!'**
  String get imageSavedSuccess;

  /// No description provided for @imageCopiedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Image copied to clipboard!'**
  String get imageCopiedSuccess;

  /// No description provided for @errorLoadImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to load image: {error}'**
  String errorLoadImage(Object error);

  /// No description provided for @errorOpenImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to open image: {error}'**
  String errorOpenImage(Object error);

  /// No description provided for @errorSaveImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to save image: {error}'**
  String errorSaveImage(Object error);

  /// No description provided for @errorCaptureImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to capture image: {error}'**
  String errorCaptureImage(Object error);

  /// No description provided for @errorCaptureImageGeneric.
  ///
  /// In en, this message translates to:
  /// **'Could not capture the image'**
  String get errorCaptureImageGeneric;

  /// No description provided for @errorCopyImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to copy image: {error}'**
  String errorCopyImage(Object error);

  /// No description provided for @toolSelectTooltip.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get toolSelectTooltip;

  /// No description provided for @toolBrushTooltip.
  ///
  /// In en, this message translates to:
  /// **'Brush'**
  String get toolBrushTooltip;

  /// No description provided for @toolHighlighterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Highlighter'**
  String get toolHighlighterTooltip;

  /// No description provided for @toolArrowTooltip.
  ///
  /// In en, this message translates to:
  /// **'Arrow'**
  String get toolArrowTooltip;

  /// No description provided for @toolRectangleTooltip.
  ///
  /// In en, this message translates to:
  /// **'Rectangle'**
  String get toolRectangleTooltip;

  /// No description provided for @toolTextTooltip.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get toolTextTooltip;

  /// No description provided for @toolEraserTooltip.
  ///
  /// In en, this message translates to:
  /// **'Eraser'**
  String get toolEraserTooltip;

  /// No description provided for @cropTooltip.
  ///
  /// In en, this message translates to:
  /// **'Crop'**
  String get cropTooltip;

  /// No description provided for @colorTooltip.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colorTooltip;

  /// No description provided for @strokeWidthTooltip.
  ///
  /// In en, this message translates to:
  /// **'Stroke width: {value}px'**
  String strokeWidthTooltip(Object value);

  /// No description provided for @strokeWidthTitle.
  ///
  /// In en, this message translates to:
  /// **'Stroke width'**
  String get strokeWidthTitle;

  /// No description provided for @okButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okButtonLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
