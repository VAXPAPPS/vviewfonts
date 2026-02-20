import '../../domain/entities/font_entity.dart';
import '../../domain/repositories/font_repository.dart';
import '../datasources/fontconfig_ffi_datasource.dart';
import '../datasources/favorites_local_datasource.dart';

/// Concrete implementation of [FontRepository].
///
/// Uses [FontconfigFfiDatasource] for reading system fonts via FFI
/// and [FavoritesLocalDatasource] for local favorites persistence.
class FontRepositoryImpl implements FontRepository {
  final FontconfigFfiDatasource _fontDatasource;
  final FavoritesLocalDatasource _favoritesDatasource;

  FontRepositoryImpl({
    required FontconfigFfiDatasource fontDatasource,
    required FavoritesLocalDatasource favoritesDatasource,
  }) : _fontDatasource = fontDatasource,
       _favoritesDatasource = favoritesDatasource;

  @override
  Future<List<FontEntity>> getAllFonts() {
    return _fontDatasource.getAllFonts();
  }

  @override
  Future<List<String>> getFavorites() {
    return _favoritesDatasource.getFavorites();
  }

  @override
  Future<void> addFavorite(String family) {
    return _favoritesDatasource.addFavorite(family);
  }

  @override
  Future<void> removeFavorite(String family) {
    return _favoritesDatasource.removeFavorite(family);
  }
}
