import 'package:equatable/equatable.dart';
import '../../../domain/entities/font_entity.dart';

/// View modes for the font list display
enum FontViewMode { list, grid }

/// States for the FontList BLoC
abstract class FontListState extends Equatable {
  const FontListState();

  @override
  List<Object?> get props => [];
}

/// Initial state before fonts are loaded
class FontListInitial extends FontListState {}

/// Loading state while fonts are being fetched via FFI
class FontListLoading extends FontListState {}

/// Fonts loaded successfully
class FontListLoaded extends FontListState {
  /// All system fonts (unfiltered)
  final List<FontEntity> allFonts;

  /// Currently displayed fonts (after search + filter)
  final List<FontEntity> displayedFonts;

  /// Current view mode
  final FontViewMode viewMode;

  /// Current search query
  final String searchQuery;

  /// Active category filter
  final FontCategory activeCategory;

  const FontListLoaded({
    required this.allFonts,
    required this.displayedFonts,
    this.viewMode = FontViewMode.list,
    this.searchQuery = '',
    this.activeCategory = FontCategory.all,
  });

  /// Create a copy with updated fields
  FontListLoaded copyWith({
    List<FontEntity>? allFonts,
    List<FontEntity>? displayedFonts,
    FontViewMode? viewMode,
    String? searchQuery,
    FontCategory? activeCategory,
  }) {
    return FontListLoaded(
      allFonts: allFonts ?? this.allFonts,
      displayedFonts: displayedFonts ?? this.displayedFonts,
      viewMode: viewMode ?? this.viewMode,
      searchQuery: searchQuery ?? this.searchQuery,
      activeCategory: activeCategory ?? this.activeCategory,
    );
  }

  @override
  List<Object?> get props => [
    allFonts,
    displayedFonts,
    viewMode,
    searchQuery,
    activeCategory,
  ];
}

/// Error state
class FontListError extends FontListState {
  final String message;
  const FontListError(this.message);

  @override
  List<Object?> get props => [message];
}
