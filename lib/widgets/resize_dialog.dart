import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linux_image_editor/l10n/app_localizations.dart';

class ResizeDialog extends StatefulWidget {
  final int currentWidth;
  final int currentHeight;

  const ResizeDialog({
    super.key,
    required this.currentWidth,
    required this.currentHeight,
  });

  @override
  State<ResizeDialog> createState() => _ResizeDialogState();
}

class _ResizeDialogState extends State<ResizeDialog> {
  late TextEditingController _widthController;
  late TextEditingController _heightController;
  late TextEditingController _percentageController;
  bool _isPercentageMode = false;
  bool _maintainAspectRatio = true;
  double _aspectRatio = 1.0;

  @override
  void initState() {
    super.initState();
    _aspectRatio = widget.currentWidth / widget.currentHeight;
    _widthController = TextEditingController(
      text: widget.currentWidth.toString(),
    );
    _heightController = TextEditingController(
      text: widget.currentHeight.toString(),
    );
    _percentageController = TextEditingController(text: '100');
  }

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    _percentageController.dispose();
    super.dispose();
  }

  void _onWidthChanged(String value) {
    if (_maintainAspectRatio && value.isNotEmpty) {
      final width = int.tryParse(value);
      if (width != null) {
        final newHeight = (width / _aspectRatio).round();
        _heightController.text = newHeight.toString();
      }
    }
  }

  void _onHeightChanged(String value) {
    if (_maintainAspectRatio && value.isNotEmpty) {
      final height = int.tryParse(value);
      if (height != null) {
        final newWidth = (height * _aspectRatio).round();
        _widthController.text = newWidth.toString();
      }
    }
  }

  Map<String, int>? _getResultDimensions() {
    if (_isPercentageMode) {
      final percentage = double.tryParse(_percentageController.text);
      if (percentage == null || percentage <= 0) return null;

      final factor = percentage / 100.0;
      return {
        'width': (widget.currentWidth * factor).round(),
        'height': (widget.currentHeight * factor).round(),
      };
    } else {
      final width = int.tryParse(_widthController.text);
      final height = int.tryParse(_heightController.text);

      if (width == null || height == null || width <= 0 || height <= 0) {
        return null;
      }

      return {'width': width, 'height': height};
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final resultDimensions = _getResultDimensions();
    final isValid = resultDimensions != null;

    return Dialog(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título
            Text(
              l10n.resizeDialogTitle,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Informação da imagem atual
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.currentSizeLabel(
                      widget.currentWidth,
                      widget.currentHeight,
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Toggle entre pixels e porcentagem
            SegmentedButton<bool>(
              segments: [
                ButtonSegment<bool>(
                  value: false,
                  label: Text(l10n.pixelsLabel),
                  icon: const Icon(Icons.grid_on),
                ),
                ButtonSegment<bool>(
                  value: true,
                  label: Text(l10n.percentageLabel),
                  icon: const Icon(Icons.percent),
                ),
              ],
              selected: {_isPercentageMode},
              onSelectionChanged: (Set<bool> newSelection) {
                setState(() {
                  _isPercentageMode = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 20),

            // Campos de entrada
            if (_isPercentageMode)
              TextField(
                controller: _percentageController,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                decoration: InputDecoration(
                  labelText: l10n.percentageLabel,
                  border: const OutlineInputBorder(),
                  suffixText: '%',
                  helperText: l10n.percentageHelperText,
                ),
                onChanged: (_) => setState(() {}),
              )
            else
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _widthController,
                          autofocus: true,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            labelText: l10n.widthLabel,
                            border: const OutlineInputBorder(),
                            suffixText: 'px',
                          ),
                          onChanged: _onWidthChanged,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _heightController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            labelText: l10n.heightLabel,
                            border: const OutlineInputBorder(),
                            suffixText: 'px',
                          ),
                          onChanged: _onHeightChanged,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: _maintainAspectRatio,
                    onChanged: (value) {
                      setState(() {
                        _maintainAspectRatio = value ?? true;
                        if (_maintainAspectRatio) {
                          _onWidthChanged(_widthController.text);
                        }
                      });
                    },
                    title: Text(l10n.maintainAspectRatioLabel),
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                  ),
                ],
              ),
            const SizedBox(height: 20),

            // Preview do resultado
            if (isValid)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.newSizeLabel(
                        resultDimensions['width']!,
                        resultDimensions['height']!,
                      ),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
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
                  onPressed: isValid
                      ? () {
                          Navigator.pop(context, resultDimensions);
                        }
                      : null,
                  child: Text(l10n.applyButtonLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
