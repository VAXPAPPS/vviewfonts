import 'package:flutter_bloc/flutter_bloc.dart';
import 'font_preview_event.dart';
import 'font_preview_state.dart';

/// BLoC for managing font preview: selected font, preview text, size, and comparisons.
class FontPreviewBloc extends Bloc<FontPreviewEvent, FontPreviewState> {
  FontPreviewBloc() : super(const FontPreviewState()) {
    on<SelectFont>(_onSelectFont);
    on<ChangePreviewText>(_onChangePreviewText);
    on<ChangeFontSize>(_onChangeFontSize);
    on<AddToCompare>(_onAddToCompare);
    on<RemoveFromCompare>(_onRemoveFromCompare);
    on<ClearCompare>(_onClearCompare);
  }

  void _onSelectFont(SelectFont event, Emitter<FontPreviewState> emit) {
    emit(state.copyWith(selectedFont: event.font));
  }

  void _onChangePreviewText(
    ChangePreviewText event,
    Emitter<FontPreviewState> emit,
  ) {
    emit(state.copyWith(previewText: event.text));
  }

  void _onChangeFontSize(ChangeFontSize event, Emitter<FontPreviewState> emit) {
    emit(state.copyWith(fontSize: event.size.clamp(8.0, 120.0)));
  }

  void _onAddToCompare(AddToCompare event, Emitter<FontPreviewState> emit) {
    if (state.compareFonts.length >= 4) return; // Max 4 fonts for comparison
    if (state.compareFonts.any(
      (f) => f.family == event.font.family && f.style == event.font.style,
    )) {
      return; // Already in compare list
    }
    emit(state.copyWith(compareFonts: [...state.compareFonts, event.font]));
  }

  void _onRemoveFromCompare(
    RemoveFromCompare event,
    Emitter<FontPreviewState> emit,
  ) {
    emit(
      state.copyWith(
        compareFonts: state.compareFonts
            .where(
              (f) =>
                  !(f.family == event.font.family &&
                      f.style == event.font.style),
            )
            .toList(),
      ),
    );
  }

  void _onClearCompare(ClearCompare event, Emitter<FontPreviewState> emit) {
    emit(state.copyWith(compareFonts: []));
  }
}
