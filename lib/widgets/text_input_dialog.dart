import 'package:flutter/material.dart';
import '../models/text_style_type.dart';
import 'package:linux_image_editor/l10n/app_localizations.dart';

class TextInputDialog extends StatefulWidget {
  final Color currentColor;

  const TextInputDialog({super.key, required this.currentColor});

  @override
  State<TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<TextInputDialog> {
  final TextEditingController _textController = TextEditingController();
  TextStyleType _selectedStyle = TextStyleType.plain;
  double _fontSize = 24.0;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final previewText = _textController.text.isEmpty
        ? l10n.textPreviewPlaceholder
        : _textController.text;

    return Dialog(
      child: Container(
        width: 450,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título
              Text(
                l10n.textDialogTitle,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Campo de texto
              TextField(
                controller: _textController,
                autofocus: true,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.textInputLabel,
                  border: const OutlineInputBorder(),
                  hintText: l10n.textInputHint,
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),

              // Tamanho da fonte
              Row(
                children: [
                  Text(
                    l10n.fontSizeLabel,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_fontSize.toInt()}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _fontSize,
                min: 12,
                max: 72,
                divisions: 60,
                label: _fontSize.toInt().toString(),
                onChanged: (value) {
                  setState(() {
                    _fontSize = value;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Seletor de estilo
              Text(
                l10n.textStyleLabel,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              Row(
                children: TextStyleType.values.map((styleType) {
                  final isSelected = _selectedStyle == styleType;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedStyle = styleType;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected
                                ? Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildStyleIcon(styleType),
                              const SizedBox(height: 4),
                              Text(
                                styleType.displayName,
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Preview do texto
              Text(
                l10n.textPreviewLabel,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                constraints: const BoxConstraints(minHeight: 80),
                alignment: Alignment.center,
                child: _buildPreviewText(previewText),
              ),
              const SizedBox(height: 24),

              // Botões
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.cancelButtonLabel),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _textController.text.trim().isEmpty
                        ? null
                        : () {
                            Navigator.pop(
                              context,
                              TextConfig(
                                text: _textController.text,
                                styleType: _selectedStyle,
                                fontSize: _fontSize,
                                color: widget.currentColor,
                              ),
                            );
                          },
                    child: Text(l10n.okButtonLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStyleIcon(TextStyleType styleType) {
    switch (styleType) {
      case TextStyleType.plain:
        return const Icon(Icons.text_fields, size: 32);
      case TextStyleType.shadow:
        return Stack(
          children: [
            Positioned(
              left: 2,
              top: 2,
              child: Icon(Icons.text_fields, size: 32, color: Colors.grey[400]),
            ),
            const Icon(Icons.text_fields, size: 32),
          ],
        );
      case TextStyleType.roundedBox:
        return Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: widget.currentColor.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.text_fields,
                size: 24,
                color: Colors.white,
              ),
            ),
          ],
        );
    }
  }

  Widget _buildPreviewText(String text) {
    final config = TextConfig(
      text: text,
      styleType: _selectedStyle,
      fontSize: _fontSize,
      color: widget.currentColor,
    );
    final styleConfig = _selectedStyle.config;

    Widget textWidget = Text(
      text,
      style: config.getTextStyle(),
      textAlign: TextAlign.center,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );

    // Adicionar fundo arredondado se necessário
    if (styleConfig.hasBackground) {
      textWidget = Container(
        padding: styleConfig.backgroundPadding,
        decoration: BoxDecoration(
          color: widget.currentColor.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(styleConfig.borderRadius),
        ),
        child: Text(
          text,
          style: config.getTextStyle().copyWith(color: Colors.white),
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    return textWidget;
  }
}
