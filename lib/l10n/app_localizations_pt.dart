// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Linux Image Editor';

  @override
  String get openImageTooltip => 'Abrir imagem (Ctrl+O)';

  @override
  String get pasteFromClipboardTooltip =>
      'Colar da area de transferencia (Ctrl+V)';

  @override
  String get saveTooltip => 'Salvar (Ctrl+S)';

  @override
  String get saveAsTooltip => 'Salvar como (Ctrl+Shift+S)';

  @override
  String get copyButtonLabel => 'Copiar';

  @override
  String get undoTooltip => 'Desfazer (Ctrl+Z)';

  @override
  String get clearAllTooltip => 'Apagar todas alterações';

  @override
  String get previousFileTooltip => 'Arquivo anterior';

  @override
  String get nextFileTooltip => 'Próximo arquivo';

  @override
  String previousFileWithName(Object fileName) {
    return 'Anterior: $fileName';
  }

  @override
  String nextFileWithName(Object fileName) {
    return 'Próximo: $fileName';
  }

  @override
  String get fileNavigationTooltip => 'Ir para arquivo';

  @override
  String get sortByTooltip => 'Ordenar por';

  @override
  String get sortByName => 'Nome';

  @override
  String get sortByDate => 'Data';

  @override
  String get closeTooltip => 'Fechar';

  @override
  String get noImageLoadedTitle => 'Nenhuma imagem carregada';

  @override
  String get emptyStateHintLine1 =>
      'Copie um screenshot e ele aparecera aqui automaticamente';

  @override
  String get emptyStateHintLine2 =>
      'Ou abra uma imagem ou passe um arquivo via linha de comando';

  @override
  String get openImageButtonLabel => 'Abrir imagem';

  @override
  String get pasteButtonLabel => 'Colar';

  @override
  String get zoomInTooltip => 'Aumentar zoom';

  @override
  String get zoomOutTooltip => 'Diminuir zoom';

  @override
  String get zoomResetTooltip => 'Resetar zoom (100%)';

  @override
  String get cancelButtonLabel => 'Cancelar';

  @override
  String get applyCropButtonLabel => 'Aplicar corte';

  @override
  String get saveImageDialogTitle => 'Salvar imagem';

  @override
  String get defaultEditedFileName => 'screenshot_editado.png';

  @override
  String get noImageToSave => 'Nenhuma imagem para salvar';

  @override
  String get imageSavedSuccess => 'Imagem salva com sucesso!';

  @override
  String get imageCopiedSuccess =>
      'Imagem copiada para a area de transferencia!';

  @override
  String errorLoadImage(Object error) {
    return 'Erro ao carregar imagem: $error';
  }

  @override
  String errorOpenImage(Object error) {
    return 'Erro ao abrir imagem: $error';
  }

  @override
  String errorSaveImage(Object error) {
    return 'Erro ao salvar imagem: $error';
  }

  @override
  String errorCaptureImage(Object error) {
    return 'Erro ao capturar imagem: $error';
  }

  @override
  String get errorCaptureImageGeneric => 'Nao foi possivel capturar a imagem';

  @override
  String errorCopyImage(Object error) {
    return 'Erro ao copiar imagem: $error';
  }

  @override
  String get toolSelectTooltip => 'Selecionar';

  @override
  String get toolBrushTooltip => 'Pincel';

  @override
  String get toolHighlighterTooltip => 'Marca-texto';

  @override
  String get toolArrowTooltip => 'Seta';

  @override
  String get toolRectangleTooltip => 'Retangulo';

  @override
  String get toolTextTooltip => 'Texto';

  @override
  String get toolEraserTooltip => 'Borracha';

  @override
  String get cropTooltip => 'Cortar';

  @override
  String get colorTooltip => 'Cor';

  @override
  String strokeWidthTooltip(Object value) {
    return 'Espessura: ${value}px';
  }

  @override
  String get strokeWidthTitle => 'Espessura';

  @override
  String get okButtonLabel => 'OK';

  @override
  String get textDialogTitle => 'Adicionar Texto';

  @override
  String get textInputLabel => 'Texto';

  @override
  String get textInputHint => 'Digite o texto aqui...';

  @override
  String get fontSizeLabel => 'Tamanho da fonte:';

  @override
  String get textStyleLabel => 'Estilo do texto';

  @override
  String get textPreviewLabel => 'Visualização';

  @override
  String get textPreviewPlaceholder => 'Texto de exemplo';

  @override
  String get resizeTooltip => 'Redimensionar';

  @override
  String get resizeDialogTitle => 'Redimensionar Imagem';

  @override
  String currentSizeLabel(Object width, Object height) {
    return 'Atual: $width x $height px';
  }

  @override
  String get pixelsLabel => 'Pixels';

  @override
  String get percentageLabel => 'Porcentagem';

  @override
  String get percentageHelperText => 'ex: 50 para metade, 200 para dobro';

  @override
  String get widthLabel => 'Largura';

  @override
  String get heightLabel => 'Altura';

  @override
  String get maintainAspectRatioLabel => 'Manter proporção';

  @override
  String newSizeLabel(Object width, Object height) {
    return 'Novo tamanho: $width x $height px';
  }

  @override
  String get applyButtonLabel => 'Aplicar';

  @override
  String get errorResizeImage => 'Erro ao redimensionar imagem';

  @override
  String get imageResizedSuccess => 'Imagem redimensionada com sucesso!';

  @override
  String get aspectRatioFree => 'Livre';

  @override
  String get fixedSizeLabel => 'Tamanho Fixo (px)';

  @override
  String get fixedSizeDialogTitle => 'Corte com Tamanho Fixo';

  @override
  String get fixedSizeDialogDescription =>
      'Digite as dimensões em pixels. A área de corte será fixa e você poderá apenas reposicioná-la.';
}
