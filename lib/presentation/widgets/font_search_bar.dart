import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/font_list/font_list_bloc.dart';
import '../../application/font_list/font_list_event.dart';
import '../../application/font_list/font_list_state.dart';

/// Search bar for filtering fonts by name.
class FontSearchBar extends StatefulWidget {
  const FontSearchBar({super.key});

  @override
  State<FontSearchBar> createState() => _FontSearchBarState();
}

class _FontSearchBarState extends State<FontSearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FontListBloc, FontListState>(
      listenWhen: (prev, curr) {
        // Reset search when fonts are reloaded
        if (prev is FontListLoading && curr is FontListLoaded) return true;
        return false;
      },
      listener: (context, state) {
        _controller.clear();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: _isFocused ? 0.12 : 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isFocused
                ? Colors.white.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Search fonts...',
            hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 13,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.white.withValues(alpha: 0.4),
              size: 18,
            ),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Colors.white.withValues(alpha: 0.4),
                      size: 16,
                    ),
                    onPressed: () {
                      _controller.clear();
                      context.read<FontListBloc>().add(const SearchFonts(''));
                      setState(() {});
                    },
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            isDense: true,
          ),
          onChanged: (value) {
            context.read<FontListBloc>().add(SearchFonts(value));
            setState(() {});
          },
        ),
      ),
    );
  }
}
