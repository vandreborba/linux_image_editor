import 'package:flutter/material.dart';
import '../models/editor_tool.dart';

class EditorToolbar extends StatelessWidget {
  final EditorTool selectedTool;
  final Color selectedColor;
  final double strokeWidth;
  final Function(EditorTool) onToolSelected;
  final Function(Color) onColorChanged;
  final Function(double) onStrokeWidthChanged;
  final VoidCallback onCropPressed;

  const EditorToolbar({
    super.key,
    required this.selectedTool,
    required this.selectedColor,
    required this.strokeWidth,
    required this.onToolSelected,
    required this.onColorChanged,
    required this.onStrokeWidthChanged,
    required this.onCropPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildToolButton(
            context,
            icon: Icons.near_me,
            tool: EditorTool.none,
            tooltip: 'Selecionar',
          ),
          const SizedBox(height: 4),
          const Divider(height: 1),
          const SizedBox(height: 8),
          _buildToolButton(
            context,
            icon: Icons.brush,
            tool: EditorTool.brush,
            tooltip: 'Pincel',
          ),
          const SizedBox(height: 4),
          _buildToolButton(
            context,
            icon: Icons.highlight,
            tool: EditorTool.highlighter,
            tooltip: 'Marca-texto',
          ),
          const SizedBox(height: 4),
          _buildToolButton(
            context,
            icon: Icons.arrow_forward,
            tool: EditorTool.arrow,
            tooltip: 'Seta',
          ),
          const SizedBox(height: 4),
          _buildToolButton(
            context,
            icon: Icons.rectangle_outlined,
            tool: EditorTool.rectangle,
            tooltip: 'Retângulo',
          ),
          const SizedBox(height: 4),
          _buildToolButton(
            context,
            icon: Icons.text_fields,
            tool: EditorTool.text,
            tooltip: 'Texto',
          ),
          const SizedBox(height: 4),
          _buildToolButton(
            context,
            icon: Icons.cleaning_services,
            tool: EditorTool.eraser,
            tooltip: 'Borracha',
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),
          _buildCropButton(context),
          const Spacer(),
          // Controles de cor e espessura
          const Divider(height: 1),
          const SizedBox(height: 12),
          _buildColorPicker(context),
          const SizedBox(height: 12),
          _buildStrokeWidthPicker(context),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildToolButton(
    BuildContext context, {
    required IconData icon,
    required EditorTool tool,
    required String tooltip,
  }) {
    final isSelected = selectedTool == tool;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: IconButton(
          icon: Icon(icon),
          onPressed: () => onToolSelected(tool),
          tooltip: tooltip,
          color: isSelected
              ? Theme.of(context).colorScheme.onPrimaryContainer
              : Theme.of(context).colorScheme.onSurface,
          iconSize: 24,
        ),
      ),
    );
  }

  Widget _buildCropButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.transparent,
        ),
        child: IconButton(
          icon: const Icon(Icons.crop),
          onPressed: onCropPressed,
          tooltip: 'Cortar',
          color: Theme.of(context).colorScheme.onSurface,
          iconSize: 24,
        ),
      ),
    );
  }

  Widget _buildColorPicker(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: PopupMenuButton<Color>(
        initialValue: selectedColor,
        onSelected: onColorChanged,
        tooltip: 'Cor',
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: selectedColor,
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        itemBuilder: (context) {
          final colors = [
            Colors.red,
            Colors.red.shade700,
            Colors.orange,
            Colors.orange.shade700,
            Colors.yellow,
            Colors.yellow.shade700,
            Colors.green,
            Colors.green.shade700,
            Colors.blue,
            Colors.blue.shade700,
            Colors.cyan,
            Colors.cyan.shade700,
            Colors.purple,
            Colors.purple.shade700,
            Colors.pink,
            Colors.pink.shade700,
            Colors.brown,
            Colors.brown.shade700,
            Colors.grey,
            Colors.grey.shade700,
            Colors.black,
            Colors.white,
          ];
          return [
            PopupMenuItem<Color>(
              enabled: false,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: colors.map((color) {
                  return InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      onColorChanged(color);
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(
                          color: selectedColor == color
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                          width: selectedColor == color ? 3 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ];
        },
      ),
    );
  }

  Widget _buildStrokeWidthPicker(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: () {
          _showStrokeWidthPicker(context);
        },
        child: Tooltip(
          message: 'Espessura: ${strokeWidth.toInt()}px',
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.line_weight,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(height: 4),
                Text(
                  '${strokeWidth.toInt()}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showStrokeWidthPicker(BuildContext context) {
    double localStrokeWidth = strokeWidth;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Espessura',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 20),
                    Slider(
                      value: localStrokeWidth,
                      min: 1,
                      max: 20,
                      divisions: 19,
                      label: localStrokeWidth.toInt().toString(),
                      onChanged: (value) {
                        setState(() {
                          localStrokeWidth = value;
                        });
                        onStrokeWidthChanged(value);
                      },
                    ),
                    const SizedBox(height: 16),
                    // Preview da espessura
                    Container(
                      height: 60,
                      alignment: Alignment.center,
                      child: Container(
                        width: 150,
                        height: localStrokeWidth.clamp(1.0, 40.0),
                        decoration: BoxDecoration(
                          color: selectedColor,
                          borderRadius: BorderRadius.circular(
                            localStrokeWidth / 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
