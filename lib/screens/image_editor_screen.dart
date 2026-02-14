import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_painter_v2/flutter_painter.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:window_manager/window_manager.dart';
import 'package:linux_image_editor/l10n/app_localizations.dart';
import '../models/editor_tool.dart';
import '../models/editor_mode.dart';
import '../widgets/toolbar.dart';

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
      }
    } catch (e) {
      _showError(AppLocalizations.of(context)!.errorLoadImage(e.toString()));
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
        });
      }
    } catch (e) {
      // Silenciosamente ignora erros ao tentar ler da área de transferência
      // (pode não haver imagem ou não ter permissão)
      debugPrint('Não foi possível ler imagem da área de transferência: $e');
    }
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
    _currentScale = 1.0;
  }

  void _zoomIn() {
    setState(() {
      _currentScale = (_currentScale * 1.2).clamp(0.1, 4.0);
      _transformationController.value = Matrix4.identity()
        ..scale(_currentScale);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentScale = (_currentScale / 1.2).clamp(0.1, 4.0);
      _transformationController.value = Matrix4.identity()
        ..scale(_currentScale);
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
      _showError(AppLocalizations.of(context)!.errorOpenImage(e.toString()));
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

      await Pasteboard.writeImage(imageBytes);
      _showSuccess(l10n.imageCopiedSuccess);
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
          break;

        case EditorTool.highlighter:
          _painterController.freeStyleMode = FreeStyleMode.draw;
          _painterController.shapeFactory = null;
          _painterController.freeStyleColor = _selectedColor.withValues(
            alpha: 0.4,
          );
          _painterController.freeStyleStrokeWidth = _strokeWidth * 3;
          break;

        case EditorTool.arrow:
          _painterController.freeStyleMode = FreeStyleMode.none;
          _painterController.shapeFactory = ArrowFactory();
          break;

        case EditorTool.rectangle:
          _painterController.freeStyleMode = FreeStyleMode.none;
          _painterController.shapeFactory = RectangleFactory();
          break;

        case EditorTool.text:
          _painterController.freeStyleMode = FreeStyleMode.none;
          _painterController.shapeFactory = null;
          _painterController.addText();
          break;

        case EditorTool.eraser:
          _painterController.freeStyleMode = FreeStyleMode.erase;
          _painterController.shapeFactory = null;
          break;

        case EditorTool.none:
          _painterController.freeStyleMode = FreeStyleMode.none;
          _painterController.shapeFactory = null;
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

  void _applyCrop(CropResult result) async {
    switch (result) {
      case CropSuccess(:final croppedImage):
        final uiImage = await _bytesToUiImage(croppedImage);
        setState(() {
          _imageData = croppedImage;
          _currentImage = uiImage;
          _painterController.background = uiImage.backgroundDrawable;
          _mode = EditorMode.draw;
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
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: DragToMoveArea(
                child: AppBar(
                  title: Text(l10n.appTitle),
                  actions: [
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
                                    child: InteractiveViewer(
                                      transformationController:
                                          _transformationController,
                                      minScale: 0.1,
                                      maxScale: 4.0,
                                      boundaryMargin: const EdgeInsets.all(80),
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
                                                ? SizedBox(
                                                    width: _currentImage!.width
                                                        .toDouble(),
                                                    height: _currentImage!
                                                        .height
                                                        .toDouble(),
                                                    child: FlutterPainter(
                                                      controller:
                                                          _painterController,
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
        Expanded(
          child: Crop(
            image: _imageData!,
            controller: _cropController,
            onCropped: _applyCrop,
            withCircleUi: false,
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
