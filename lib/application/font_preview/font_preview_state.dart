import 'package:equatable/equatable.dart';
import '../../../domain/entities/font_entity.dart';

/// State for the FontPreview BLoC
class FontPreviewState extends Equatable {
  /// Currently selected font for detailed preview
  final FontEntity? selectedFont;

  /// Text to display in the preview
  final String previewText;

  /// Font size for the preview
  final double fontSize;

  /// Fonts selected for side-by-side comparison
  final List<FontEntity> compareFonts;

  static const String defaultPreviewText =
      'The quick brown fox jumps over the lazy dog\n'
      'أبجد هوز حطي كلمن سعفص قرشت\n'
      'ABCDEFGHIJKLMNOPQRSTUVWXYZ\n'
      'abcdefghijklmnopqrstuvwxyz\n'
      '0123456789 !@#\$%^&*()';

  const FontPreviewState({
    this.selectedFont,
    this.previewText = defaultPreviewText,
    this.fontSize = 24.0,
    this.compareFonts = const [],
  });

  FontPreviewState copyWith({
    FontEntity? selectedFont,
    String? previewText,
    double? fontSize,
    List<FontEntity>? compareFonts,
  }) {
    return FontPreviewState(
      selectedFont: selectedFont ?? this.selectedFont,
      previewText: previewText ?? this.previewText,
      fontSize: fontSize ?? this.fontSize,
      compareFonts: compareFonts ?? this.compareFonts,
    );
  }

  @override
  List<Object?> get props => [
    selectedFont,
    previewText,
    fontSize,
    compareFonts,
  ];
}
