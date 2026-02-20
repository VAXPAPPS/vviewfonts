import '../entities/font_entity.dart';

/// Abstract repository contract for font operations.
///
/// Implemented by [FontRepositoryImpl] in the data layer.
abstract class FontRepository {
  /// Fetches all installed system fonts via fontconfig FFI.
  Future<List<FontEntity>> getAllFonts();

  /// Gets the list of favorite font family names.
  Future<List<String>> getFavorites();

  /// Adds a font family to favorites.
  Future<void> addFavorite(String family);

  /// Removes a font family from favorites.
  Future<void> removeFavorite(String family);
}
