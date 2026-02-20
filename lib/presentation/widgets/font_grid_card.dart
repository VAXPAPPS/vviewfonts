import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/font_entity.dart';
import '../../application/font_preview/font_preview_bloc.dart';
import '../../application/font_preview/font_preview_event.dart';
import '../../application/favorites/favorites_bloc.dart';
import '../../application/favorites/favorites_event.dart';
import '../../application/favorites/favorites_state.dart';

/// Font card for the grid view mode.
class FontGridCard extends StatefulWidget {
  final FontEntity font;
  final bool isSelected;

  const FontGridCard({super.key, required this.font, required this.isSelected});

  @override
  State<FontGridCard> createState() => _FontGridCardState();
}

class _FontGridCardState extends State<FontGridCard> {
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
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? Colors.white.withOpacity(0.1)
                : _hovered
                ? Colors.white.withOpacity(0.06)
                : Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isSelected
                  ? Colors.white.withOpacity(0.2)
                  : _hovered
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.05),
            ),
          ),
          child: Stack(
            children: [
              // Font preview content
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Font name
                    Text(
                      widget.font.family,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${widget.font.style} • ${widget.font.category.displayName}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 9,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Preview text
                    Flexible(
                      child: Text(
                        'Aa Bb Cc',
                        style: TextStyle(
                          fontFamily: widget.font.family,
                          fontSize: 24,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Hover action buttons
              if (_hovered || widget.isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _GridAction(
                        icon: Icons.copy_rounded,
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(text: widget.font.family),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Copied: ${widget.font.family}'),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.white.withOpacity(0.15),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 4),
                      BlocBuilder<FavoritesBloc, FavoritesState>(
                        builder: (context, favState) {
                          final isFav =
                              favState is FavoritesLoaded &&
                              favState.isFavorite(widget.font.family);
                          return _GridAction(
                            icon: isFav
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: isFav ? const Color(0xFFFFBD2E) : null,
                            onTap: () {
                              context.read<FavoritesBloc>().add(
                                ToggleFavorite(widget.font.family),
                              );
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

class _GridAction extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _GridAction({required this.icon, required this.onTap, this.color});

  @override
  State<_GridAction> createState() => _GridActionState();
}

class _GridActionState extends State<_GridAction> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _hovered
                ? Colors.black.withOpacity(0.5)
                : Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            widget.icon,
            size: 14,
            color: widget.color ?? Colors.white.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}
