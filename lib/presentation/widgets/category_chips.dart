import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/font_entity.dart';
import '../../application/font_list/font_list_bloc.dart';
import '../../application/font_list/font_list_event.dart';
import '../../application/font_list/font_list_state.dart';

/// Chips bar for filtering fonts by category.
class CategoryChips extends StatelessWidget {
  const CategoryChips({super.key});

  static const _categories = [
    FontCategory.all,
    FontCategory.sansSerif,
    FontCategory.serif,
    FontCategory.monospace,
    FontCategory.other,
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FontListBloc, FontListState>(
      buildWhen: (prev, curr) {
        if (prev is FontListLoaded && curr is FontListLoaded) {
          return prev.activeCategory != curr.activeCategory;
        }
        return true;
      },
      builder: (context, state) {
        final activeCategory = state is FontListLoaded
            ? state.activeCategory
            : FontCategory.all;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _categories.map((cat) {
              final isActive = cat == activeCategory;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _CategoryChip(
                  label: cat.displayName,
                  isActive: isActive,
                  onTap: () {
                    context.read<FontListBloc>().add(FilterByCategory(cat));
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _CategoryChip extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<_CategoryChip> {
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
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: widget.isActive
                ? Colors.white.withValues(alpha: 0.15)
                : _hovered
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isActive
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w400,
              color: widget.isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }
}
