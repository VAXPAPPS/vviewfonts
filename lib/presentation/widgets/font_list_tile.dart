import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/font_entity.dart';
import '../../application/font_preview/font_preview_bloc.dart';
import '../../application/font_preview/font_preview_event.dart';
import '../../application/font_preview/font_preview_state.dart';
import '../../application/favorites/favorites_bloc.dart';
import '../../application/favorites/favorites_event.dart';
import '../../application/favorites/favorites_state.dart';

/// A single font item in the sidebar list.
class FontListTile extends StatefulWidget {
  final FontEntity font;
  final bool isSelected;

  const FontListTile({super.key, required this.font, required this.isSelected});

  @override
  State<FontListTile> createState() => _FontListTileState();
}

class _FontListTileState extends State<FontListTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.read<FontPreviewBloc>().add(SelectFont(widget.font));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? Colors.white.withValues(alpha: 0.12)
                : _hovered
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: widget.isSelected
                ? Border.all(color: Colors.white.withValues(alpha: 0.15))
                : null,
          ),
          child: Row(
            children: [
              // Font info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.font.family,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${widget.font.style} • ${widget.font.category.displayName}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Action buttons (visible on hover or selected)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: _hovered || widget.isSelected ? 1.0 : 0.0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Copy name button
                    _ActionIcon(
                      icon: Icons.copy_rounded,
                      tooltip: 'Copy font name',
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: widget.font.family),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Copied: ${widget.font.family}'),
                            duration: const Duration(seconds: 1),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.white.withValues(alpha: 0.15),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 4),
                    // Favorite button
                    BlocBuilder<FavoritesBloc, FavoritesState>(
                      builder: (context, favState) {
                        final isFav =
                            favState is FavoritesLoaded &&
                            favState.isFavorite(widget.font.family);
                        return _ActionIcon(
                          icon: isFav
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          tooltip: isFav
                              ? 'Remove from favorites'
                              : 'Add to favorites',
                          color: isFav ? const Color(0xFFFFBD2E) : null,
                          onTap: () {
                            context.read<FavoritesBloc>().add(
                              ToggleFavorite(widget.font.family),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(width: 4),
                    // Compare button
                    BlocBuilder<FontPreviewBloc, FontPreviewState>(
                      builder: (context, previewState) {
                        final isInCompare = previewState.compareFonts.any(
                          (f) =>
                              f.family == widget.font.family &&
                              f.style == widget.font.style,
                        );
                        return _ActionIcon(
                          icon: isInCompare
                              ? Icons.compare_rounded
                              : Icons.compare_outlined,
                          tooltip: isInCompare
                              ? 'Remove from compare'
                              : 'Add to compare',
                          color: isInCompare ? const Color(0xFF28C840) : null,
                          onTap: () {
                            final bloc = context.read<FontPreviewBloc>();
                            if (isInCompare) {
                              bloc.add(RemoveFromCompare(widget.font));
                            } else {
                              bloc.add(AddToCompare(widget.font));
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionIcon extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? color;

  const _ActionIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color,
  });

  @override
  State<_ActionIcon> createState() => _ActionIconState();
}

class _ActionIconState extends State<_ActionIcon> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: widget.tooltip,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _hovered
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              widget.icon,
              size: 14,
              color: widget.color ?? Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}
