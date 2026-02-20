import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/font_entity.dart';
import '../../../domain/repositories/font_repository.dart';
import 'font_list_event.dart';
import 'font_list_state.dart';

/// BLoC for managing the font list: loading, searching, filtering, and view mode.
class FontListBloc extends Bloc<FontListEvent, FontListState> {
  final FontRepository _repository;

  FontListBloc({required FontRepository repository})
    : _repository = repository,
      super(FontListInitial()) {
    on<LoadFonts>(_onLoadFonts);
    on<SearchFonts>(_onSearchFonts);
    on<FilterByCategory>(_onFilterByCategory);
    on<ToggleViewMode>(_onToggleViewMode);
  }

  Future<void> _onLoadFonts(
    LoadFonts event,
    Emitter<FontListState> emit,
  ) async {
    emit(FontListLoading());
    try {
      final fonts = await _repository.getAllFonts();
      emit(FontListLoaded(allFonts: fonts, displayedFonts: fonts));
    } catch (e) {
      emit(FontListError('Failed to load fonts: $e'));
    }
  }

  void _onSearchFonts(SearchFonts event, Emitter<FontListState> emit) {
    final currentState = state;
    if (currentState is FontListLoaded) {
      final filtered = _applyFilters(
        currentState.allFonts,
        event.query,
        currentState.activeCategory,
      );
      emit(
        currentState.copyWith(
          searchQuery: event.query,
          displayedFonts: filtered,
        ),
      );
    }
  }

  void _onFilterByCategory(
    FilterByCategory event,
    Emitter<FontListState> emit,
  ) {
    final currentState = state;
    if (currentState is FontListLoaded) {
      final filtered = _applyFilters(
        currentState.allFonts,
        currentState.searchQuery,
        event.category,
      );
      emit(
        currentState.copyWith(
          activeCategory: event.category,
          displayedFonts: filtered,
        ),
      );
    }
  }

  void _onToggleViewMode(ToggleViewMode event, Emitter<FontListState> emit) {
    final currentState = state;
    if (currentState is FontListLoaded) {
      emit(
        currentState.copyWith(
          viewMode: currentState.viewMode == FontViewMode.list
              ? FontViewMode.grid
              : FontViewMode.list,
        ),
      );
    }
  }

  /// Applies both search query and category filter to the font list.
  List<FontEntity> _applyFilters(
    List<FontEntity> allFonts,
    String query,
    FontCategory category,
  ) {
    var result = allFonts;

    // Apply category filter
    if (category != FontCategory.all) {
      result = result.where((f) => f.category == category).toList();
    }

    // Apply search filter
    if (query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      result = result.where((f) {
        return f.family.toLowerCase().contains(lowerQuery) ||
            f.style.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    return result;
  }
}
