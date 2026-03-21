import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/font_preview/font_preview_bloc.dart';
import '../../application/font_preview/font_preview_event.dart';
import '../../application/font_preview/font_preview_state.dart';

/// Main preview panel showing the selected font with customizable text and size.
class FontPreviewPanel extends StatelessWidget {
  const FontPreviewPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FontPreviewBloc, FontPreviewState>(
      builder: (context, state) {
        if (state.selectedFont == null) {
          return _buildEmptyState();
        }

        final font = state.selectedFont!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Font name header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          font.family,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${font.style} • ${font.weightName} • ${font.fileExtension.toUpperCase()}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Font size display
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${state.fontSize.round()}px',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Font size slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(
                    Icons.text_decrease,
                    color: Colors.white.withValues(alpha: 0.4),
                    size: 16,
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: Colors.white.withValues(alpha: 0.3),
                        inactiveTrackColor: Colors.white.withValues(alpha: 0.08),
                        thumbColor: Colors.white,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                        trackHeight: 2,
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 12,
                        ),
                      ),
                      child: Slider(
                        value: state.fontSize,
                        min: 8,
                        max: 120,
                        onChanged: (v) {
                          context.read<FontPreviewBloc>().add(
                            ChangeFontSize(v),
                          );
                        },
                      ),
                    ),
                  ),
                  Icon(
                    Icons.text_increase,
                    color: Colors.white.withValues(alpha: 0.4),
                    size: 16,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Preview text input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: TextField(
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type custom preview text...',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.2),
                      fontSize: 12,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.edit_note,
                        color: Colors.white.withValues(alpha: 0.3),
                        size: 16,
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minHeight: 0,
                      minWidth: 0,
                    ),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      context.read<FontPreviewBloc>().add(
                        ChangePreviewText(value),
                      );
                    } else {
                      context.read<FontPreviewBloc>().add(
                        const ChangePreviewText(
                          FontPreviewState.defaultPreviewText,
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
            const SizedBox(height: 16),

            // Font preview area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SelectableText(
                  state.previewText,
                  style: TextStyle(
                    fontFamily: font.family,
                    fontSize: state.fontSize,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.font_download_outlined,
            size: 64,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          Text(
            'Select a font to preview',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
