import 'package:equatable/equatable.dart';

/// States for the Favorites BLoC
abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class FavoritesInitial extends FavoritesState {}

/// Favorites loaded successfully
class FavoritesLoaded extends FavoritesState {
  /// Set of favorite font family names
  final Set<String> favoriteNames;

  const FavoritesLoaded({required this.favoriteNames});

  /// Check if a font family is favorited
  bool isFavorite(String family) => favoriteNames.contains(family);

  @override
  List<Object?> get props => [favoriteNames];
}
