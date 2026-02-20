import 'package:equatable/equatable.dart';
import '../../../domain/entities/font_entity.dart';

/// Events for the FontPreview BLoC
abstract class FontPreviewEvent extends Equatable {
  const FontPreviewEvent();

  @override
  List<Object?> get props => [];
}

/// Selects a font for preview
class SelectFont extends FontPreviewEvent {
  final FontEntity font;
  const SelectFont(this.font);

  @override
  List<Object?> get props => [font];
}

/// Changes the preview text
class ChangePreviewText extends FontPreviewEvent {
  final String text;
  const ChangePreviewText(this.text);

  @override
  List<Object?> get props => [text];
}

/// Changes the preview font size
class ChangeFontSize extends FontPreviewEvent {
  final double size;
  const ChangeFontSize(this.size);

  @override
  List<Object?> get props => [size];
}

/// Adds a font to the compare list
class AddToCompare extends FontPreviewEvent {
  final FontEntity font;
  const AddToCompare(this.font);

  @override
  List<Object?> get props => [font];
}

/// Removes a font from the compare list
class RemoveFromCompare extends FontPreviewEvent {
  final FontEntity font;
  const RemoveFromCompare(this.font);

  @override
  List<Object?> get props => [font];
}

/// Clears all fonts from compare list
class ClearCompare extends FontPreviewEvent {}
