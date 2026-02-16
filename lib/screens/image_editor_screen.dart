// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_painter_v2/flutter_painter.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:image/image.dart' as img;
import 'package:linux_image_editor/l10n/app_localizations.dart';
import '../models/editor_tool.dart';
import '../models/editor_mode.dart';
import '../models/arrow_style.dart';
import '../models/text_style_type.dart';
import '../models/file_sort_type.dart';
import '../factories/arrow_factory.dart';
import '../drawables/rounded_box_text_drawable.dart';
import '../widgets/toolbar.dart';
import '../widgets/text_input_dialog.dart';
import '../widgets/resize_dialog.dart';

class ImageEditorScreen extends StatefulWidget {
  final String? initialFilePath;

  const ImageEditorScreen({super.key, this.initialFilePath});

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  Uint8List? _imageData;
  String? _currentFilePath;
  EditorMode _mode = EditorMode.draw;
  EditorTool _selectedTool = EditorTool.none;
  late PainterController _painterController;
  final CropController _cropController = CropController();
  Color _selectedColor = Colors.red;
  double _strokeWidth = 3.0;
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  final TransformationController _transformationController =
      TransformationController();
  double _currentScale = 1.0;
  ui.Image? _currentImage;
  ArrowStyle _arrowStyle = ArrowStyle.standard;
  bool _showArrowStyleSelector = false;

  // Variáveis para navegação entre arquivos
  List<String> _filesInDirectory = [];
  int _currentFileIndex = -1;
  FileSortType _fileSortType = FileSortType.name;

  // Variáveis para pan com botão direito do mouse
  bool _isRightMouseButtonDown = false;
  Offset? _lastPanPosition;

  // Variáveis para cursor customizado da borracha
  Offset? _mousePosition;
  bool _isMouseOverCanvas = false;

  // Variável para aspect ratio no crop
  double? _selectedAspectRatio;
  Rect? _fixedCropSize;

  @override
  void initState() {
    super.initState();
    _painterController = PainterController(
      settings: PainterSettings(
        freeStyle: FreeStyleSettings(
          color: _selectedColor,
          strokeWidth: _strokeWidth,
        ),
        shape: ShapeSettings(
          paint: Paint()
            ..color = _selectedColor
            ..strokeWidth = _strokeWidth
            ..style = PaintingStyle.stroke,
        ),
        text: TextSettings(
          textStyle: TextStyle(color: _selectedColor, fontSize: 24),
        ),
      ),
    );

    // Aguarda um pouco antes de tentar carregar da área de transferência
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialFilePath != null) {
        _loadImageFromFile(widget.initialFilePath!);
      } else {
        // Se não houver arquivo inicial, tenta carregar da área de transferência
        _loadImageFromClipboard();
      }
    });
  }

  @override
  void dispose() {
    _painterController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _loadImageFromFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final uiImage = await _bytesToUiImage(bytes);
        setState(() {
          _imageData = bytes;
          _currentFilePath = path;
          _currentImage = uiImage;
          _painterController.background = uiImage.backgroundDrawable;
          _resetZoom();
        });
        // Atualiza a lista de arquivos na pasta
        await _updateFilesInDirectory(path);
      }
    } catch (e) {
      if (mounted) {
        _showError(AppLocalizations.of(context)!.errorLoadImage(e.toString()));
      }
    }
  }

  Future<ui.Image> _bytesToUiImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  Future<void> _loadImageFromClipboard() async {
    try {
      final imageBytes = await Pasteboard.image;
      if (imageBytes != null && imageBytes.isNotEmpty) {
        final uiImage = await _bytesToUiImage(imageBytes);
        setState(() {
          _imageData = imageBytes;
          _currentFilePath =
              null; // Não tem arquivo, veio da área de transferência
          _currentImage = uiImage;
          _painterController.background = uiImage.backgroundDrawable;
          _resetZoom();
          // Limpa a lista de arquivos quando carrega da área de transferência
          _filesInDirectory = [];
          _currentFileIndex = -1;
        });
      }
    } catch (e) {
      // Silenciosamente ignora erros ao tentar ler da área de transferência
      // (pode não haver imagem ou não ter permissão)
      debugPrint('Não foi possível ler imagem da área de transferência: $e');
    }
  }

  Future<void> _updateFilesInDirectory(String filePath) async {
    try {
      final file = File(filePath);
      final directory = file.parent;

      // Lista todos os arquivos de imagem na pasta
      final imageExtensions = [
        '.png',
        '.jpg',
        '.jpeg',
        '.gif',
        '.bmp',
        '.webp',
      ];
      final files = directory
          .listSync()
          .whereType<File>()
          .where(
            (f) => imageExtensions.any(
              (ext) => f.path.toLowerCase().endsWith(ext),
            ),
          )
          .toList();

      // Ordena os arquivos
      _sortFiles(files);

      setState(() {
        _filesInDirectory = files.map((f) => f.path).toList();
        _currentFileIndex = _filesInDirectory.indexOf(filePath);
      });
    } catch (e) {
      debugPrint('Erro ao listar arquivos do diretório: $e');
    }
  }

  void _sortFiles(List<File> files) {
    switch (_fileSortType) {
      case FileSortType.name:
        files.sort(
          (a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()),
        );
        break;
      case FileSortType.date:
        files.sort((a, b) {
          final aStat = a.statSync();
          final bStat = b.statSync();
          return bStat.modified.compareTo(
            aStat.modified,
          ); // Mais recente primeiro
        });
        break;
    }
  }

  Future<void> _changeSortType(FileSortType newType) async {
    setState(() {
      _fileSortType = newType;
    });
    // Reordena a lista se houver arquivos carregados
    if (_currentFilePath != null) {
      await _updateFilesInDirectory(_currentFilePath!);
    }
  }

  void _navigateToFile(int direction) {
    if (_filesInDirectory.isEmpty || _currentFileIndex == -1) return;

    final newIndex = _currentFileIndex + direction;
    if (newIndex >= 0 && newIndex < _filesInDirectory.length) {
      _loadImageFromFile(_filesInDirectory[newIndex]);
    }
  }

  bool get _canNavigatePrevious =>
      _filesInDirectory.isNotEmpty && _currentFileIndex > 0;

  bool get _canNavigateNext =>
      _filesInDirectory.isNotEmpty &&
      _currentFileIndex < _filesInDirectory.length - 1;

  String? get _currentFileName {
    if (_filesInDirectory.isEmpty || _currentFileIndex == -1) return null;
    return _filesInDirectory[_currentFileIndex].split('/').last;
  }

  String? get _previousFileName {
    if (!_canNavigatePrevious) return null;
    return _filesInDirectory[_currentFileIndex - 1].split('/').last;
  }

  String? get _nextFileName {
    if (!_canNavigateNext) return null;
    return _filesInDirectory[_currentFileIndex + 1].split('/').last;
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
    _currentScale = 1.0;
  }

  void _zoomIn() {
    setState(() {
      _currentScale = (_currentScale * 1.2).clamp(0.1, 4.0);
      _transformationController.value = Matrix4.diagonal3Values(
        _currentScale,
        _currentScale,
        1.0,
      );
    });
  }

  void _zoomOut() {
    setState(() {
      _currentScale = (_currentScale / 1.2).clamp(0.1, 4.0);
      _transformationController.value = Matrix4.diagonal3Values(
        _currentScale,
        _currentScale,
        1.0,
      );
    });
  }

  void _zoomReset() {
    setState(() {
      _resetZoom();
    });
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        await _loadImageFromFile(result.files.single.path!);
      }
    } catch (e) {
      if (mounted) {
        _showError(AppLocalizations.of(context)!.errorOpenImage(e.toString()));
      }
    }
  }

  Future<void> _saveImage({bool saveAs = false}) async {
    final l10n = AppLocalizations.of(context)!;
    if (_imageData == null) {
      _showError(l10n.noImageToSave);
      return;
    }

    try {
      String? savePath = _currentFilePath;

      if (saveAs || savePath == null) {
        final result = await FilePicker.platform.saveFile(
          dialogTitle: l10n.saveImageDialogTitle,
          fileName: l10n.defaultEditedFileName,
          type: FileType.image,
        );

        if (result == null) return;
        savePath = result;
      }

      final imageBytes = await _captureImage();
      if (imageBytes != null) {
        await File(savePath).writeAsBytes(imageBytes);
        setState(() {
          _currentFilePath = savePath;
        });
        _showSuccess(l10n.imageSavedSuccess);
      }
    } catch (e) {
      _showError(l10n.errorSaveImage(e.toString()));
    }
  }

  Future<Uint8List?> _captureImage() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      // Pequeno delay para garantir que o RepaintBoundary está pronto
      await Future.delayed(const Duration(milliseconds: 100));

      final boundary =
          _repaintBoundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        debugPrint('RepaintBoundary not found');
        return null;
      }

      // Usa pixelRatio maior para melhor qualidade
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      _showError(l10n.errorCaptureImage(e.toString()));
      debugPrint('Error capturing image: $e');
      return null;
    }
  }

  Future<void> _copyToClipboard() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final imageBytes = await _captureImage();
      if (imageBytes == null) {
        _showError(l10n.errorCaptureImageGeneric);
        return;
      }

      // No Linux, usar xclip para copiar imagens
      if (Platform.isLinux) {
        // Salvar a imagem em um arquivo temporário
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/clipboard_image.png');
        await tempFile.writeAsBytes(imageBytes);

        // Usar xclip para copiar a imagem
        try {
          final result = await Process.run('xclip', [
            '-selection',
            'clipboard',
            '-t',
            'image/png',
            '-i',
            tempFile.path,
          ]);

          if (result.exitCode == 0) {
            _showSuccess(l10n.imageCopiedSuccess);
          } else {
            throw Exception('xclip failed: ${result.stderr}');
          }
        } catch (e) {
          if (e.toString().contains('No such file or directory')) {
            _showError(
              'xclip não está instalado. Por favor, instale com: sudo apt install xclip',
            );
          } else {
            rethrow;
          }
        } finally {
          // Limpar o arquivo temporário
          Future.delayed(const Duration(seconds: 1), () {
            if (tempFile.existsSync()) {
              tempFile.delete();
            }
          });
        }
      } else {
        // Em outras plataformas, usar Pasteboard
        await Pasteboard.writeImage(imageBytes);
        _showSuccess(l10n.imageCopiedSuccess);
      }
    } catch (e) {
      _showError(l10n.errorCopyImage(e.toString()));
      debugPrint('Error copying to clipboard: $e');
    }
  }

  void _updateTool(EditorTool tool) {
    setState(() {
      _selectedTool = tool;

      switch (tool) {
        case EditorTool.brush:
          _painterController.freeStyleMode = FreeStyleMode.draw;
          _painterController.shapeFactory = null;
          _painterController.freeStyleColor = _selectedColor;
          _painterController.freeStyleStrokeWidth = _strokeWidth;
          _showArrowStyleSelector = false;
          break;

        case EditorTool.highlighter:
          _painterController.freeStyleMode = FreeStyleMode.draw;
          _painterController.shapeFactory = null;
          _painterController.freeStyleColor = _selectedColor.withValues(
            alpha: 0.4,
          );
          _painterController.freeStyleStrokeWidth = _strokeWidth * 3;
          _showArrowStyleSelector = false;
          break;

        case EditorTool.arrow:
          _painterController.freeStyleMode = FreeStyleMode.none;
          _painterController.shapeFactory = StyledArrowFactory(_arrowStyle);
          _showArrowStyleSelector = true;
          break;

        case EditorTool.rectangle:
          _painterController.freeStyleMode = FreeStyleMode.none;
          _painterController.shapeFactory = RectangleFactory();
          _showArrowStyleSelector = false;
          break;

        case EditorTool.text:
          _painterController.freeStyleMode = FreeStyleMode.none;
          _painterController.shapeFactory = null;
          _showArrowStyleSelector = false;
          _showTextInputDialog();
          break;

        case EditorTool.eraser:
          _painterController.freeStyleMode = FreeStyleMode.erase;
          _painterController.shapeFactory = null;
          _painterController.freeStyleStrokeWidth = _strokeWidth;
          _showArrowStyleSelector = false;
          break;

        case EditorTool.none:
          _painterController.freeStyleMode = FreeStyleMode.none;
          _painterController.shapeFactory = null;
          _showArrowStyleSelector = false;
          break;
      }
    });
  }

  void _updateColor(Color color) {
    setState(() {
      _selectedColor = color;
      // Reaplica a ferramenta atual para garantir que a cor seja atualizada corretamente
      final currentTool = _selectedTool;
      _updateToolSettings(currentTool, color, _strokeWidth);
    });
  }

  void _updateToolSettings(EditorTool tool, Color color, double strokeWidth) {
    _painterController.freeStyleColor = color;
    _painterController.textStyle = _painterController.textStyle.copyWith(
      color: color,
    );
    _painterController.shapePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Reaplica configurações específicas da ferramenta
    if (tool == EditorTool.highlighter) {
      _painterController.freeStyleColor = color.withValues(alpha: 0.4);
      _painterController.freeStyleStrokeWidth = strokeWidth * 3;
    } else if (tool == EditorTool.brush) {
      _painterController.freeStyleStrokeWidth = strokeWidth;
    } else if (tool == EditorTool.eraser) {
      _painterController.freeStyleStrokeWidth = strokeWidth;
    }
  }

  void _updateStrokeWidth(double width) {
    setState(() {
      _strokeWidth = width;
      // Reaplica a ferramenta atual para garantir que a espessura seja atualizada corretamente
      final currentTool = _selectedTool;
      _updateToolSettings(currentTool, _selectedColor, width);
    });
  }

  void _updateArrowStyle(ArrowStyle style) {
    setState(() {
      _arrowStyle = style;
      // Se a ferramenta seta estiver selecionada, reaplica a factory com o novo estilo
      if (_selectedTool == EditorTool.arrow) {
        _painterController.shapeFactory = StyledArrowFactory(style);
      }
      // Fecha o seletor após escolher o estilo
      _showArrowStyleSelector = false;
    });
  }

  void _clearAllEdits() {
    setState(() {
      // Remove todos os drawables do controller, mantendo apenas o background
      if (_currentImage != null) {
        // Descarta o controller antigo
        _painterController.dispose();

        // Cria um novo controller limpo
        _painterController = PainterController(
          settings: PainterSettings(
            freeStyle: FreeStyleSettings(
              color: _selectedColor,
              strokeWidth: _strokeWidth,
            ),
            shape: ShapeSettings(
              paint: Paint()
                ..color = _selectedColor
                ..strokeWidth = _strokeWidth
                ..style = PaintingStyle.stroke,
            ),
            text: TextSettings(
              textStyle: TextStyle(color: _selectedColor, fontSize: 24),
            ),
          ),
        );
        _painterController.background = _currentImage!.backgroundDrawable;
        // Reaplica a ferramenta atual
        _updateTool(_selectedTool);
      }
    });
  }

  Future<void> _showTextInputDialog() async {
    final textConfig = await showDialog<TextConfig>(
      context: context,
      builder: (BuildContext context) {
        return TextInputDialog(currentColor: _selectedColor);
      },
    );

    if (textConfig != null && mounted) {
      // Atualiza o estilo de texto no controller com base na configuração
      final styleConfig = textConfig.styleType.config;

      // Calcula a posição central do canvas para adicionar o texto
      final renderBox = context.findRenderObject() as RenderBox?;
      final centerPosition = renderBox != null
          ? Offset(renderBox.size.width / 2, renderBox.size.height / 2)
          : const Offset(200, 200);

      // Cria o drawable apropriado baseado no estilo
      if (textConfig.styleType == TextStyleType.roundedBox) {
        // Usa drawable customizado para caixa arredondada
        final roundedBoxDrawable = RoundedBoxTextDrawable(
          text: textConfig.text,
          position: centerPosition,
          backgroundColor: textConfig.color.withValues(alpha: 0.7),
          padding: styleConfig.backgroundPadding,
          borderRadius: styleConfig.borderRadius,
          style: TextStyle(
            color: Colors.white,
            fontSize: textConfig.fontSize,
            fontWeight: FontWeight.w500,
          ),
        );
        _painterController.addDrawables([roundedBoxDrawable]);
      } else {
        // Usa TextDrawable padrão para texto simples ou com sombra
        TextStyle textStyle = TextStyle(
          color: textConfig.color,
          fontSize: textConfig.fontSize,
          fontWeight: FontWeight.w500,
        );

        // Adiciona sombra se necessário
        if (styleConfig.hasShadow) {
          textStyle = textStyle.copyWith(
            shadows: [
              Shadow(
                offset: styleConfig.shadowOffset,
                blurRadius: styleConfig.shadowBlurRadius,
                color: styleConfig.shadowColor,
              ),
            ],
          );
        }

        final textDrawable = TextDrawable(
          text: textConfig.text,
          position: centerPosition,
          style: textStyle,
        );

        _painterController.addDrawables([textDrawable]);
      }
    }
  }

  void _applyCrop(CropResult result) async {
    switch (result) {
      case CropSuccess(:final croppedImage):
        var finalImage = croppedImage;

        // Se há um tamanho fixo definido, redimensiona para as dimensões exatas
        if (_fixedCropSize != null) {
          final image = img.decodeImage(croppedImage);
          if (image != null) {
            final resized = img.copyResize(
              image,
              width: _fixedCropSize!.width.toInt(),
              height: _fixedCropSize!.height.toInt(),
              interpolation: img.Interpolation.linear,
            );
            finalImage = Uint8List.fromList(img.encodePng(resized));
          }
        }

        final uiImage = await _bytesToUiImage(finalImage);
        setState(() {
          _imageData = finalImage;
          _currentImage = uiImage;
          _painterController.background = uiImage.backgroundDrawable;
          _mode = EditorMode.draw;
          _fixedCropSize = null; // Reset após aplicar
          _resetZoom();
        });
      case CropFailure():
        _showError('Could not crop the image');
    }
  }

  void _enterCropMode() {
    setState(() {
      _mode = EditorMode.crop;
    });
  }

  Future<void> _showResizeDialog() async {
    if (_currentImage == null) return;

    final result = await showDialog<Map<String, int>>(
      context: context,
      builder: (context) => ResizeDialog(
        currentWidth: _currentImage!.width,
        currentHeight: _currentImage!.height,
      ),
    );

    if (result != null) {
      await _applyResize(result['width']!, result['height']!);
    }
  }

  Future<void> _applyResize(int newWidth, int newHeight) async {
    final l10n = AppLocalizations.of(context)!;

    if (_imageData == null) return;

    try {
      // Decodifica a imagem
      final image = img.decodeImage(_imageData!);
      if (image == null) {
        _showError(l10n.errorResizeImage);
        return;
      }

      // Redimensiona a imagem
      final resized = img.copyResize(
        image,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.linear,
      );

      // Codifica de volta para PNG
      final resizedBytes = Uint8List.fromList(img.encodePng(resized));

      // Converte para ui.Image
      final uiImage = await _bytesToUiImage(resizedBytes);

      // Atualiza o estado
      setState(() {
        _imageData = resizedBytes;
        _currentImage = uiImage;
        _painterController.background = uiImage.backgroundDrawable;
        _resetZoom();
      });

      _showSuccess(l10n.imageResizedSuccess);
    } catch (e) {
      _showError(l10n.errorResizeImage);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyO):
            const _OpenImageIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyV):
            const _PasteImageIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS):
            const _SaveImageIntent(),
        LogicalKeySet(
          LogicalKeyboardKey.control,
          LogicalKeyboardKey.shift,
          LogicalKeyboardKey.keyS,
        ): const _SaveAsImageIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyC):
            const _CopyImageIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyZ):
            const _UndoIntent(),
        LogicalKeySet(LogicalKeyboardKey.delete): const _DeleteDrawableIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _OpenImageIntent: CallbackAction<_OpenImageIntent>(
            onInvoke: (_) => _pickImage(),
          ),
          _PasteImageIntent: CallbackAction<_PasteImageIntent>(
            onInvoke: (_) => _loadImageFromClipboard(),
          ),
          _SaveImageIntent: CallbackAction<_SaveImageIntent>(
            onInvoke: (_) => _saveImage(saveAs: false),
          ),
          _SaveAsImageIntent: CallbackAction<_SaveAsImageIntent>(
            onInvoke: (_) => _saveImage(saveAs: true),
          ),
          _CopyImageIntent: CallbackAction<_CopyImageIntent>(
            onInvoke: (_) => _copyToClipboard(),
          ),
          _UndoIntent: CallbackAction<_UndoIntent>(
            onInvoke: (_) {
              if (_painterController.canUndo) {
                _painterController.undo();
              }
              return null;
            },
          ),
          _DeleteDrawableIntent: CallbackAction<_DeleteDrawableIntent>(
            onInvoke: (_) {
              // Verifica se há um drawable selecionado
              if (_painterController.selectedObjectDrawable != null) {
                // Armazena referência antes de remover
                final selectedDrawable =
                    _painterController.selectedObjectDrawable!;
                // Remove o drawable (newAction: true permite desfazer)
                _painterController.removeDrawable(
                  selectedDrawable,
                  newAction: true,
                );
                // Desseleciona (isRemoved: true envia evento de limpeza)
                _painterController.deselectObjectDrawable(isRemoved: true);
              }
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          onKeyEvent: (node, event) {
            // Captura a tecla Delete diretamente
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.delete) {
              if (_painterController.selectedObjectDrawable != null) {
                final selectedDrawable =
                    _painterController.selectedObjectDrawable!;
                _painterController.removeDrawable(
                  selectedDrawable,
                  newAction: true,
                );
                _painterController.deselectObjectDrawable(isRemoved: true);
                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          },
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: DragToMoveArea(
                child: AppBar(
                  title: _currentFileName != null
                      ? Text(_currentFileName!)
                      : Text(l10n.appTitle),
                  actions: [
                    // Controles de navegação entre arquivos
                    if (_filesInDirectory.isNotEmpty) ...[
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _canNavigatePrevious
                            ? () => _navigateToFile(-1)
                            : null,
                        tooltip: _previousFileName != null
                            ? l10n.previousFileWithName(_previousFileName!)
                            : l10n.previousFileTooltip,
                      ),
                      // Indicador de posição e menu dropdown
                      PopupMenuButton<int>(
                        icon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${_currentFileIndex + 1} / ${_filesInDirectory.length}',
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_drop_down, size: 20),
                          ],
                        ),
                        tooltip: l10n.fileNavigationTooltip,
                        itemBuilder: (context) {
                          return List.generate(_filesInDirectory.length, (
                            index,
                          ) {
                            final fileName = _filesInDirectory[index]
                                .split('/')
                                .last;
                            final isCurrentFile = index == _currentFileIndex;
                            return PopupMenuItem<int>(
                              value: index,
                              child: Row(
                                children: [
                                  if (isCurrentFile)
                                    Icon(
                                      Icons.check,
                                      size: 18,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    )
                                  else
                                    const SizedBox(width: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      fileName,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: isCurrentFile
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isCurrentFile
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.primary
                                            : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          });
                        },
                        onSelected: (index) {
                          if (index != _currentFileIndex) {
                            _loadImageFromFile(_filesInDirectory[index]);
                          }
                        },
                      ),
                      PopupMenuButton<FileSortType>(
                        icon: const Icon(Icons.sort),
                        tooltip: l10n.sortByTooltip,
                        initialValue: _fileSortType,
                        onSelected: _changeSortType,
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: FileSortType.name,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.sort_by_alpha,
                                  size: 20,
                                  color: _fileSortType == FileSortType.name
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                Text(l10n.sortByName),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: FileSortType.date,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 20,
                                  color: _fileSortType == FileSortType.date
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                Text(l10n.sortByDate),
                              ],
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _canNavigateNext
                            ? () => _navigateToFile(1)
                            : null,
                        tooltip: _nextFileName != null
                            ? l10n.nextFileWithName(_nextFileName!)
                            : l10n.nextFileTooltip,
                      ),
                      const VerticalDivider(),
                    ],
                    IconButton(
                      icon: const Icon(Icons.folder_open),
                      onPressed: _pickImage,
                      tooltip: l10n.openImageTooltip,
                    ),
                    IconButton(
                      icon: const Icon(Icons.content_paste),
                      onPressed: _loadImageFromClipboard,
                      tooltip: l10n.pasteFromClipboardTooltip,
                    ),
                    if (_imageData != null) ...[
                      IconButton(
                        icon: const Icon(Icons.save),
                        onPressed: () => _saveImage(saveAs: false),
                        tooltip: l10n.saveTooltip,
                      ),
                      IconButton(
                        icon: const Icon(Icons.save_as),
                        onPressed: () => _saveImage(saveAs: true),
                        tooltip: l10n.saveAsTooltip,
                      ),
                      const SizedBox(width: 8),
                      FilledButton.tonalIcon(
                        icon: const Icon(Icons.content_copy),
                        label: Text(l10n.copyButtonLabel),
                        onPressed: _copyToClipboard,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green.withValues(alpha: 0.2),
                          foregroundColor: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const VerticalDivider(),
                      IconButton(
                        icon: const Icon(Icons.undo),
                        onPressed: _painterController.canUndo
                            ? () => _painterController.undo()
                            : null,
                        tooltip: l10n.undoTooltip,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_sweep),
                        onPressed: _imageData != null ? _clearAllEdits : null,
                        tooltip: l10n.clearAllTooltip,
                      ),
                    ],
                    const SizedBox(width: 8),
                    // Botão fechar
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () async {
                        await windowManager.close();
                      },
                      tooltip: l10n.closeTooltip,
                    ),
                  ],
                ),
              ),
            ),
            body: _imageData == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: 100,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l10n.noImageLoadedTitle,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l10n.emptyStateHintLine1,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          l10n.emptyStateHintLine2,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FilledButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.folder_open),
                              label: Text(l10n.openImageButtonLabel),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: _loadImageFromClipboard,
                              icon: const Icon(Icons.content_paste),
                              label: Text(l10n.pasteButtonLabel),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : Row(
                    children: [
                      // Toolbar lateral
                      if (_mode == EditorMode.draw)
                        EditorToolbar(
                          selectedTool: _selectedTool,
                          selectedColor: _selectedColor,
                          strokeWidth: _strokeWidth,
                          onToolSelected: _updateTool,
                          onColorChanged: _updateColor,
                          onStrokeWidthChanged: _updateStrokeWidth,
                          onCropPressed: _enterCropMode,
                          onResizePressed: _showResizeDialog,
                        ),

                      // Canvas
                      Expanded(
                        child: _mode == EditorMode.draw
                            ? Stack(
                                children: [
                                  // Canvas com zoom e pan
                                  Container(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerLowest,
                                    child: Listener(
                                      onPointerDown: (event) {
                                        // Detecta quando o botão direito (botão 2) ou botão do meio (botão 4) do mouse é pressionado
                                        if (event.buttons == 2 ||
                                            event.buttons == 4) {
                                          setState(() {
                                            _isRightMouseButtonDown = true;
                                            _lastPanPosition = event.position;
                                          });
                                        }
                                      },
                                      onPointerMove: (event) {
                                        // Move a imagem quando o botão direito está pressionado
                                        if (_isRightMouseButtonDown &&
                                            _lastPanPosition != null) {
                                          final delta =
                                              event.position -
                                              _lastPanPosition!;

                                          // Cria uma matriz de translação e multiplica com a transformação atual
                                          final translation = Matrix4.identity()
                                            ..setTranslationRaw(
                                              delta.dx,
                                              delta.dy,
                                              0,
                                            );
                                          final currentTransform =
                                              translation *
                                              _transformationController.value;

                                          setState(() {
                                            _transformationController.value =
                                                currentTransform;
                                            _lastPanPosition = event.position;
                                          });
                                        }
                                      },
                                      onPointerUp: (event) {
                                        // Reseta o estado quando o botão é solto
                                        if (event.buttons != 2 &&
                                            event.buttons != 4) {
                                          setState(() {
                                            _isRightMouseButtonDown = false;
                                            _lastPanPosition = null;
                                          });
                                        }
                                      },
                                      onPointerCancel: (event) {
                                        // Reseta o estado se o evento for cancelado
                                        setState(() {
                                          _isRightMouseButtonDown = false;
                                          _lastPanPosition = null;
                                        });
                                      },
                                      child: InteractiveViewer(
                                        transformationController:
                                            _transformationController,
                                        minScale: 0.1,
                                        maxScale: 4.0,
                                        boundaryMargin: const EdgeInsets.all(
                                          80,
                                        ),
                                        constrained: false,
                                        onInteractionUpdate: (details) {
                                          setState(() {
                                            _currentScale =
                                                _transformationController.value
                                                    .getMaxScaleOnAxis();
                                          });
                                        },
                                        child: Center(
                                          child: Card(
                                            elevation: 8,
                                            margin: const EdgeInsets.all(20),
                                            clipBehavior: Clip.antiAlias,
                                            child: RepaintBoundary(
                                              key: _repaintBoundaryKey,
                                              child: _currentImage != null
                                                  ? MouseRegion(
                                                      cursor:
                                                          _selectedTool ==
                                                              EditorTool.eraser
                                                          ? SystemMouseCursors
                                                                .none
                                                          : MouseCursor.defer,
                                                      onEnter: (_) {
                                                        setState(() {
                                                          _isMouseOverCanvas =
                                                              true;
                                                        });
                                                      },
                                                      onExit: (_) {
                                                        setState(() {
                                                          _isMouseOverCanvas =
                                                              false;
                                                        });
                                                      },
                                                      onHover: (event) {
                                                        setState(() {
                                                          _mousePosition = event
                                                              .localPosition;
                                                        });
                                                      },
                                                      child: Stack(
                                                        children: [
                                                          SizedBox(
                                                            width:
                                                                _currentImage!
                                                                    .width
                                                                    .toDouble(),
                                                            height:
                                                                _currentImage!
                                                                    .height
                                                                    .toDouble(),
                                                            child: FlutterPainter(
                                                              controller:
                                                                  _painterController,
                                                            ),
                                                          ),
                                                          // Overlay do cursor da borracha
                                                          if (_selectedTool ==
                                                                  EditorTool
                                                                      .eraser &&
                                                              _isMouseOverCanvas &&
                                                              _mousePosition !=
                                                                  null)
                                                            Positioned(
                                                              left:
                                                                  _mousePosition!
                                                                      .dx -
                                                                  _strokeWidth /
                                                                      2,
                                                              top:
                                                                  _mousePosition!
                                                                      .dy -
                                                                  _strokeWidth /
                                                                      2,
                                                              child: IgnorePointer(
                                                                child: Container(
                                                                  width:
                                                                      _strokeWidth,
                                                                  height:
                                                                      _strokeWidth,
                                                                  decoration: BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    border: Border.all(
                                                                      color: Colors
                                                                          .black,
                                                                      width: 2,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    )
                                                  : FlutterPainter(
                                                      controller:
                                                          _painterController,
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Controles de zoom
                                  Positioned(
                                    right: 16,
                                    bottom: 16,
                                    child: Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.add),
                                              onPressed: _zoomIn,
                                              tooltip: l10n.zoomInTooltip,
                                            ),
                                            Text(
                                              '${(_currentScale * 100).toInt()}%',
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodySmall,
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.remove),
                                              onPressed: _zoomOut,
                                              tooltip: l10n.zoomOutTooltip,
                                            ),
                                            const Divider(),
                                            IconButton(
                                              icon: const Icon(Icons.refresh),
                                              onPressed: _zoomReset,
                                              tooltip: l10n.zoomResetTooltip,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Seletor de estilo de seta (visível apenas quando a ferramenta seta está selecionada)
                                  if (_selectedTool == EditorTool.arrow &&
                                      _showArrowStyleSelector)
                                    Positioned(
                                      top: 16,
                                      left: 16,
                                      child: Card(
                                        elevation: 4,
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Estilo da Seta',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleSmall
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.close,
                                                      size: 18,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        _showArrowStyleSelector =
                                                            false;
                                                      });
                                                    },
                                                    padding: EdgeInsets.zero,
                                                    constraints:
                                                        const BoxConstraints(),
                                                    tooltip: 'Fechar',
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              ...ArrowStyle.values.map((style) {
                                                final isSelected =
                                                    _arrowStyle == style;
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        bottom: 4.0,
                                                      ),
                                                  child: Material(
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                      onTap: () =>
                                                          _updateArrowStyle(
                                                            style,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 12,
                                                              vertical: 8,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: isSelected
                                                              ? Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .primaryContainer
                                                              : Colors
                                                                    .transparent,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                          border: Border.all(
                                                            color: isSelected
                                                                ? Theme.of(
                                                                        context,
                                                                      )
                                                                      .colorScheme
                                                                      .primary
                                                                : Colors
                                                                      .transparent,
                                                            width: 2,
                                                          ),
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                  style ==
                                                                          ArrowStyle
                                                                              .standard
                                                                      ? Icons
                                                                            .arrow_forward
                                                                      : style ==
                                                                            ArrowStyle.wide
                                                                      ? Icons
                                                                            .arrow_right_alt
                                                                      : Icons
                                                                            .turn_right,
                                                                  size: 20,
                                                                  color:
                                                                      isSelected
                                                                      ? Theme.of(
                                                                          context,
                                                                        ).colorScheme.onPrimaryContainer
                                                                      : Theme.of(
                                                                          context,
                                                                        ).colorScheme.onSurface,
                                                                ),
                                                                const SizedBox(
                                                                  width: 8,
                                                                ),
                                                                Text(
                                                                  style
                                                                      .displayName,
                                                                  style: TextStyle(
                                                                    fontWeight:
                                                                        isSelected
                                                                        ? FontWeight
                                                                              .bold
                                                                        : FontWeight
                                                                              .normal,
                                                                    color:
                                                                        isSelected
                                                                        ? Theme.of(
                                                                            context,
                                                                          ).colorScheme.onPrimaryContainer
                                                                        : Theme.of(
                                                                            context,
                                                                          ).colorScheme.onSurface,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 4,
                                                            ),
                                                            Text(
                                                              style.description,
                                                              style: Theme.of(context)
                                                                  .textTheme
                                                                  .bodySmall
                                                                  ?.copyWith(
                                                                    color:
                                                                        isSelected
                                                                        ? Theme.of(
                                                                            context,
                                                                          ).colorScheme.onPrimaryContainer
                                                                        : Theme.of(
                                                                            context,
                                                                          ).colorScheme.onSurfaceVariant,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              )
                            : _buildCropView(),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildCropView() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        // Aspect ratio presets
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _buildAspectRatioChip(l10n.aspectRatioFree, null, l10n),
                  _buildAspectRatioChip('1:1', 1.0, l10n),
                  _buildAspectRatioChip('4:3', 4.0 / 3.0, l10n),
                  _buildAspectRatioChip('16:9', 16.0 / 9.0, l10n),
                  _buildAspectRatioChip('3:2', 3.0 / 2.0, l10n),
                  _buildAspectRatioChip('9:16', 9.0 / 16.0, l10n),
                ],
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _showFixedSizeCropDialog,
                icon: const Icon(Icons.crop_din, size: 18),
                label: Text(l10n.fixedSizeLabel),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
              if (_fixedCropSize != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Chip(
                    label: Text(
                      '${_fixedCropSize!.width.toInt()} x ${_fixedCropSize!.height.toInt()} px',
                      style: const TextStyle(fontSize: 12),
                    ),
                    onDeleted: () {
                      setState(() {
                        _fixedCropSize = null;
                      });
                    },
                    deleteIcon: const Icon(Icons.close, size: 16),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: Crop(
            key: ValueKey(
              '${_selectedAspectRatio}_${_fixedCropSize?.width}_${_fixedCropSize?.height}',
            ),
            image: _imageData!,
            controller: _cropController,
            onCropped: _applyCrop,
            withCircleUi: false,
            aspectRatio: _fixedCropSize == null
                ? _selectedAspectRatio
                : (_fixedCropSize!.width / _fixedCropSize!.height),
            maskColor: Colors.black.withValues(alpha: 0.5),
            cornerDotBuilder: (size, edgeAlignment) {
              return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _mode = EditorMode.draw;
                  });
                },
                child: Text(l10n.cancelButtonLabel),
              ),
              const SizedBox(width: 16),
              FilledButton.icon(
                onPressed: () => _cropController.crop(),
                icon: const Icon(Icons.crop),
                label: Text(l10n.applyCropButtonLabel),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAspectRatioChip(
    String label,
    double? aspectRatio,
    AppLocalizations l10n,
  ) {
    final isSelected =
        _selectedAspectRatio == aspectRatio && _fixedCropSize == null;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedAspectRatio = aspectRatio;
          _fixedCropSize = null;
        });
      },
    );
  }

  Future<void> _showFixedSizeCropDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final widthController = TextEditingController();
    final heightController = TextEditingController();

    final result = await showDialog<Map<String, int>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.fixedSizeDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.fixedSizeDialogDescription,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widthController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.widthLabel,
                      suffixText: 'px',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: heightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.heightLabel,
                      suffixText: 'px',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () {
              final width = int.tryParse(widthController.text);
              final height = int.tryParse(heightController.text);
              if (width != null && height != null && width > 0 && height > 0) {
                Navigator.pop(context, {'width': width, 'height': height});
              }
            },
            child: Text(l10n.okButtonLabel),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _selectedAspectRatio = null;
        _fixedCropSize = Rect.fromLTWH(
          0,
          0,
          result['width']!.toDouble(),
          result['height']!.toDouble(),
        );
      });
    }
  }
}

// Intent classes for keyboard shortcuts
class _OpenImageIntent extends Intent {
  const _OpenImageIntent();
}

class _PasteImageIntent extends Intent {
  const _PasteImageIntent();
}

class _SaveImageIntent extends Intent {
  const _SaveImageIntent();
}

class _SaveAsImageIntent extends Intent {
  const _SaveAsImageIntent();
}

class _CopyImageIntent extends Intent {
  const _CopyImageIntent();
}

class _UndoIntent extends Intent {
  const _UndoIntent();
}

class _DeleteDrawableIntent extends Intent {
  const _DeleteDrawableIntent();
}
