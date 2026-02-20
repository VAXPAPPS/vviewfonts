import 'package:shared_preferences/shared_preferences.dart';

/// Local data source for managing favorite fonts using SharedPreferences.
class FavoritesLocalDatasource {
  static const String _favoritesKey = 'vaxp_font_favorites';

  /// Gets all favorite font family names.
  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  /// Adds a font family to favorites.
  Future<void> addFavorite(String family) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];
    if (!favorites.contains(family)) {
      favorites.add(family);
      await prefs.setStringList(_favoritesKey, favorites);
    }
  }

  /// Removes a font family from favorites.
  Future<void> removeFavorite(String family) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];
    favorites.remove(family);
    await prefs.setStringList(_favoritesKey, favorites);
  }
}
