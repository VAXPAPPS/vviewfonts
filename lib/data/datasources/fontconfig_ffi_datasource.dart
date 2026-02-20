import 'dart:convert';
import 'dart:ffi';
import 'dart:isolate';

// ignore: depend_on_referenced_packages
import 'package:ffi/ffi.dart';

import '../../domain/entities/font_entity.dart';

/// FFI type definitions for fontconfig_helper.c functions
typedef GetSystemFontsJsonC = Pointer<Utf8> Function();
typedef GetSystemFontsJsonDart = Pointer<Utf8> Function();

typedef FreeFontsJsonC = Void Function(Pointer<Utf8>);
typedef FreeFontsJsonDart = void Function(Pointer<Utf8>);

/// Data source that reads system fonts via FFI calls to libfontconfig.
///
/// Uses [fontconfig_helper.c] native library for maximum performance.
/// Font loading runs in a separate Isolate to keep the UI responsive.
class FontconfigFfiDatasource {
  DynamicLibrary? _lib;

  /// Loads the native fontconfig_helper shared library.
  // ignore: unused_element
  DynamicLibrary _loadLibrary() {
    if (_lib != null) return _lib!;
    _lib = DynamicLibrary.open('libfontconfig_helper.so');
    return _lib!;
  }

  /// Fetches all system fonts by calling into native fontconfig.
  ///
  /// Runs the FFI call in a separate Isolate for non-blocking operation.
  Future<List<FontEntity>> getAllFonts() async {
    // Run FFI in a separate isolate to avoid blocking UI
    final jsonString = await Isolate.run(() {
      final lib = DynamicLibrary.open('libfontconfig_helper.so');

      final getJson = lib
          .lookupFunction<GetSystemFontsJsonC, GetSystemFontsJsonDart>(
            'get_system_fonts_json',
          );
      final freeJson = lib.lookupFunction<FreeFontsJsonC, FreeFontsJsonDart>(
        'free_fonts_json',
      );

      final ptr = getJson();
      final result = ptr.toDartString();
      freeJson(ptr);

      return result;
    });

    return _parseJsonToEntities(jsonString);
  }

  /// Parses the JSON string from the native layer into FontEntity objects.
  ///
  /// Groups fonts by family and deduplicates based on unique family+style combos.
  List<FontEntity> _parseJsonToEntities(String jsonString) {
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    final Map<String, FontEntity> uniqueFonts = {};

    for (final item in jsonList) {
      final map = item as Map<String, dynamic>;
      final family = (map['family'] as String?) ?? '';
      final style = (map['style'] as String?) ?? '';
      final filePath = (map['file'] as String?) ?? '';
      final weight = (map['weight'] as int?) ?? 80;
      final slant = (map['slant'] as int?) ?? 0;
      final spacing = (map['spacing'] as int?) ?? 0;

      if (family.isEmpty) continue;

      // Use family+style as unique key to avoid duplicates
      final key = '$family|$style';
      if (uniqueFonts.containsKey(key)) continue;

      final category = _classifyFont(family, spacing);

      uniqueFonts[key] = FontEntity(
        family: family,
        style: style,
        filePath: filePath,
        weight: weight,
        slant: slant,
        spacing: spacing,
        category: category,
      );
    }

    final fonts = uniqueFonts.values.toList();
    // Sort alphabetically by family name
    fonts.sort(
      (a, b) => a.family.toLowerCase().compareTo(b.family.toLowerCase()),
    );
    return fonts;
  }

  /// Classifies a font into a category based on its name and spacing.
  FontCategory _classifyFont(String family, int spacing) {
    final lower = family.toLowerCase();

    // Monospace detection
    if (spacing == 100 || spacing == 90) return FontCategory.monospace;
    if (lower.contains('mono') ||
        lower.contains('console') ||
        lower.contains('code') ||
        lower.contains('courier') ||
        lower.contains('terminal')) {
      return FontCategory.monospace;
    }

    // Sans detection
    if (lower.contains('sans') ||
        lower.contains('gothic') ||
        lower.contains('arial') ||
        lower.contains('helvetica') ||
        lower.contains('ubuntu') ||
        lower.contains('roboto') ||
        lower.contains('inter') ||
        lower.contains('noto sans') ||
        lower.contains('liberation sans') ||
        lower.contains('nimbus sans')) {
      return FontCategory.sansSerif;
    }

    // Serif detection
    if (lower.contains('serif') ||
        lower.contains('roman') ||
        lower.contains('times') ||
        lower.contains('georgia') ||
        lower.contains('garamond') ||
        lower.contains('palatino') ||
        lower.contains('bookman') ||
        lower.contains('noto serif') ||
        lower.contains('liberation serif') ||
        lower.contains('nimbus roman')) {
      return FontCategory.serif;
    }

    return FontCategory.other;
  }
}
