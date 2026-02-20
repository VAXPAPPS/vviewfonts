import 'package:equatable/equatable.dart';

/// Represents a single font installed on the system.
///
/// Data is populated from fontconfig via FFI.
class FontEntity extends Equatable {
  /// Font family name (e.g., "Ubuntu", "Noto Sans")
  final String family;

  /// Font style (e.g., "Regular", "Bold", "Italic")
  final String style;

  /// Absolute path to the font file
  final String filePath;

  /// Font weight (fontconfig scale: 0=Thin, 80=Regular, 200=Bold, 210=Black)
  final int weight;

  /// Font slant (0=Roman, 100=Italic, 110=Oblique)
  final int slant;

  /// Font spacing (0=Proportional, 100=Mono)
  final int spacing;

  /// Computed category based on family name and spacing
  final FontCategory category;

  /// File extension (ttf, otf, etc.)
  String get fileExtension {
    final lastDot = filePath.lastIndexOf('.');
    if (lastDot == -1) return '';
    return filePath.substring(lastDot + 1).toLowerCase();
  }

  /// Human-readable weight name
  String get weightName {
    if (weight <= 0) return 'Thin';
    if (weight <= 40) return 'ExtraLight';
    if (weight <= 50) return 'Light';
    if (weight <= 55) return 'SemiLight';
    if (weight <= 75) return 'Book';
    if (weight <= 80) return 'Regular';
    if (weight <= 100) return 'Medium';
    if (weight <= 180) return 'SemiBold';
    if (weight <= 200) return 'Bold';
    if (weight <= 205) return 'ExtraBold';
    if (weight <= 210) return 'Black';
    return 'UltraBlack';
  }

  /// Human-readable slant name
  String get slantName {
    if (slant == 0) return 'Roman';
    if (slant == 100) return 'Italic';
    return 'Oblique';
  }

  /// Whether this is a monospace font
  bool get isMono => spacing == 100 || spacing == 90;

  const FontEntity({
    required this.family,
    required this.style,
    required this.filePath,
    required this.weight,
    required this.slant,
    required this.spacing,
    required this.category,
  });

  @override
  List<Object?> get props => [
    family,
    style,
    filePath,
    weight,
    slant,
    spacing,
    category,
  ];
}

/// Font category classification
enum FontCategory {
  all,
  serif,
  sansSerif,
  monospace,
  other;

  String get displayName {
    switch (this) {
      case FontCategory.all:
        return 'All';
      case FontCategory.serif:
        return 'Serif';
      case FontCategory.sansSerif:
        return 'Sans';
      case FontCategory.monospace:
        return 'Mono';
      case FontCategory.other:
        return 'Other';
    }
  }
}
