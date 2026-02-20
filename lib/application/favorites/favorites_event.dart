import 'package:equatable/equatable.dart';

/// Events for the Favorites BLoC
abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

/// Loads saved favorites from local storage
class LoadFavorites extends FavoritesEvent {}

/// Toggles a font family's favorite status
class ToggleFavorite extends FavoritesEvent {
  final String family;
  const ToggleFavorite(this.family);

  @override
  List<Object?> get props => [family];
}
