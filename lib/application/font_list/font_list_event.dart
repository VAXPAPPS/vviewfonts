import 'package:equatable/equatable.dart';
import '../../../domain/entities/font_entity.dart';

/// Events for the FontList BLoC
abstract class FontListEvent extends Equatable {
  const FontListEvent();

  @override
  List<Object?> get props => [];
}

/// Triggers loading of all system fonts
class LoadFonts extends FontListEvent {}

/// Searches fonts by name
class SearchFonts extends FontListEvent {
  final String query;
  const SearchFonts(this.query);

  @override
  List<Object?> get props => [query];
}

/// Filters fonts by category
class FilterByCategory extends FontListEvent {
  final FontCategory category;
  const FilterByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

/// Toggles between grid and list view mode
class ToggleViewMode extends FontListEvent {}
