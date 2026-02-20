import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/font_list/font_list_bloc.dart';
import '../../application/font_list/font_list_event.dart';
import '../../application/font_list/font_list_state.dart';
import '../../application/font_preview/font_preview_bloc.dart';
import '../../application/font_preview/font_preview_state.dart';
import '../widgets/font_search_bar.dart';
import '../widgets/category_chips.dart';
import '../widgets/font_list_tile.dart';
import '../widgets/font_grid_card.dart';
import '../widgets/font_preview_panel.dart';
import '../widgets/font_details_panel.dart';
import 'compare_page.dart';

/// Main page of the View Fonts app.
///
/// Layout: Sidebar (search + filters + font list) | Main Panel (preview/compare/details)
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// 0 = Preview, 1 = Compare
  int _activeTab = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ==================== SIDEBAR ====================
        SizedBox(width: 300, child: _buildSidebar()),

        // Divider
        Container(width: 1, color: Colors.white.withOpacity(0.06)),

        // ==================== MAIN CONTENT ====================
        Expanded(child: _buildMainPanel()),
      ],
    );
  }

  Widget _buildSidebar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar
        const Padding(
          padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: FontSearchBar(),
        ),

        // Category filters
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: Row(
            children: [
              const Expanded(child: CategoryChips()),
              const SizedBox(width: 8),
              // View mode toggle
              BlocBuilder<FontListBloc, FontListState>(
                buildWhen: (prev, curr) {
                  if (prev is FontListLoaded && curr is FontListLoaded) {
                    return prev.viewMode != curr.viewMode;
                  }
                  return false;
                },
                builder: (context, state) {
                  final isGrid =
                      state is FontListLoaded &&
                      state.viewMode == FontViewMode.grid;
                  return _ViewModeToggle(
                    isGrid: isGrid,
                    onTap: () {
                      context.read<FontListBloc>().add(ToggleViewMode());
                    },
                  );
                },
              ),
            ],
          ),
        ),

        // Font count
        BlocBuilder<FontListBloc, FontListState>(
          builder: (context, state) {
            if (state is FontListLoaded) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                child: Text(
                  '${state.displayedFonts.length} fonts',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),

        // Divider
        Container(height: 1, color: Colors.white.withOpacity(0.06)),

        // Font list
        Expanded(
          child: BlocBuilder<FontListBloc, FontListState>(
            builder: (context, state) {
              if (state is FontListLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white24,
                    strokeWidth: 2,
                  ),
                );
              }

              if (state is FontListError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red.withOpacity(0.5),
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          state.message,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              context.read<FontListBloc>().add(LoadFonts());
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Retry',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is FontListLoaded) {
                if (state.displayedFonts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off,
                          color: Colors.white.withOpacity(0.15),
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No fonts found',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (state.viewMode == FontViewMode.grid) {
                  return _buildGridView(state);
                }
                return _buildListView(state);
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildListView(FontListLoaded state) {
    return BlocBuilder<FontPreviewBloc, FontPreviewState>(
      buildWhen: (prev, curr) => prev.selectedFont != curr.selectedFont,
      builder: (context, previewState) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: state.displayedFonts.length,
          itemBuilder: (context, index) {
            final font = state.displayedFonts[index];
            final isSelected =
                previewState.selectedFont != null &&
                previewState.selectedFont!.family == font.family &&
                previewState.selectedFont!.style == font.style;
            return FontListTile(font: font, isSelected: isSelected);
          },
        );
      },
    );
  }

  Widget _buildGridView(FontListLoaded state) {
    return BlocBuilder<FontPreviewBloc, FontPreviewState>(
      buildWhen: (prev, curr) => prev.selectedFont != curr.selectedFont,
      builder: (context, previewState) {
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: state.displayedFonts.length,
          itemBuilder: (context, index) {
            final font = state.displayedFonts[index];
            final isSelected =
                previewState.selectedFont != null &&
                previewState.selectedFont!.family == font.family &&
                previewState.selectedFont!.style == font.style;
            return FontGridCard(font: font, isSelected: isSelected);
          },
        );
      },
    );
  }

  Widget _buildMainPanel() {
    return Column(
      children: [
        // Tab bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Row(
            children: [
              _TabButton(
                label: 'Preview',
                icon: Icons.visibility_outlined,
                isActive: _activeTab == 0,
                onTap: () => setState(() => _activeTab = 0),
              ),
              const SizedBox(width: 4),
              _TabButton(
                label: 'Compare',
                icon: Icons.compare_outlined,
                isActive: _activeTab == 1,
                onTap: () => setState(() => _activeTab = 1),
                badge: BlocBuilder<FontPreviewBloc, FontPreviewState>(
                  builder: (context, state) {
                    if (state.compareFonts.isEmpty)
                      return const SizedBox.shrink();
                    return Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF28C840).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${state.compareFonts.length}',
                        style: const TextStyle(
                          color: Color(0xFF28C840),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Tab content
        Expanded(
          child: _activeTab == 0 ? _buildPreviewTab() : const ComparePage(),
        ),
      ],
    );
  }

  Widget _buildPreviewTab() {
    return BlocBuilder<FontPreviewBloc, FontPreviewState>(
      builder: (context, state) {
        if (state.selectedFont == null) {
          return const FontPreviewPanel();
        }

        return Column(
          children: [
            // Preview panel
            const Expanded(flex: 3, child: FontPreviewPanel()),
            // Details panel
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: FontDetailsPanel(font: state.selectedFont!),
            ),
          ],
        );
      },
    );
  }
}

class _ViewModeToggle extends StatefulWidget {
  final bool isGrid;
  final VoidCallback onTap;

  const _ViewModeToggle({required this.isGrid, required this.onTap});

  @override
  State<_ViewModeToggle> createState() => _ViewModeToggleState();
}

class _ViewModeToggleState extends State<_ViewModeToggle> {
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
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _hovered
                ? Colors.white.withOpacity(0.1)
                : Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            widget.isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded,
            size: 16,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final Widget? badge;

  const _TabButton({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
    this.badge,
  });

  @override
  State<_TabButton> createState() => _TabButtonState();
}

class _TabButtonState extends State<_TabButton> {
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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isActive
                ? Colors.white.withOpacity(0.1)
                : _hovered
                ? Colors.white.withOpacity(0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 14,
                color: widget.isActive
                    ? Colors.white
                    : Colors.white.withOpacity(0.4),
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.isActive
                      ? Colors.white
                      : Colors.white.withOpacity(0.4),
                  fontSize: 12,
                  fontWeight: widget.isActive
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
              if (widget.badge != null) widget.badge!,
            ],
          ),
        ),
      ),
    );
  }
}
