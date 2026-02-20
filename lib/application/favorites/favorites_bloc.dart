import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/font_repository.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

/// BLoC for managing font favorites with local persistence.
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FontRepository _repository;

  FavoritesBloc({required FontRepository repository})
    : _repository = repository,
      super(FavoritesInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    final favorites = await _repository.getFavorites();
    emit(FavoritesLoaded(favoriteNames: favorites.toSet()));
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    final currentState = state;
    if (currentState is FavoritesLoaded) {
      final newFavorites = Set<String>.from(currentState.favoriteNames);
      if (newFavorites.contains(event.family)) {
        newFavorites.remove(event.family);
        await _repository.removeFavorite(event.family);
      } else {
        newFavorites.add(event.family);
        await _repository.addFavorite(event.family);
      }
      emit(FavoritesLoaded(favoriteNames: newFavorites));
    }
  }
}
