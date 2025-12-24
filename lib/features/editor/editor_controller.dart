import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../history/history_repo.dart';
import 'models.dart';
import 'text_processor.dart';

class EditorState {
  final String input;
  final String output;
  final RefactorSettings settings;
  final bool isProcessing;
  final String? error;

  const EditorState({
    required this.input,
    required this.output,
    required this.settings,
    this.isProcessing = false,
    this.error,
  });

  EditorState copyWith({
    String? input,
    String? output,
    RefactorSettings? settings,
    bool? isProcessing,
    String? error,
    bool clearError = false,
  }) {
    return EditorState(
      input: input ?? this.input,
      output: output ?? this.output,
      settings: settings ?? this.settings,
      isProcessing: isProcessing ?? this.isProcessing,
      error: clearError ? null : (error ?? this.error),
    );
  }

  static EditorState initial() => const EditorState(
    input: "",
    output: "",
    settings: RefactorSettings(),
    isProcessing: false,
    error: null,
  );
}

class EditorController extends StateNotifier<EditorState> {
  EditorController(this._historyRepo) : super(EditorState.initial());

  final HistoryRepo _historyRepo;

  void setInput(String v) => state = state.copyWith(input: v, clearError: true);

  void setSettings(RefactorSettings s) =>
      state = state.copyWith(settings: s, clearError: true);

  void clearAll() {
    state = EditorState.initial();
  }

  Future<void> process() async {
    try {
      state = state.copyWith(isProcessing: true, clearError: true);

      final result = await TextProcessor.processAsync(state.input, state.settings);

      state = state.copyWith(output: result, isProcessing: false);

      // Save history if there's output
      if (result.trim().isNotEmpty) {
        await _historyRepo.addEntry(
          input: state.input,
          output: result,
          settings: state.settings,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: "Erreur pendant le traitement: $e",
      );
    }
  }

  Future<void> loadFromHistory({
    required String input,
    required String output,
    required RefactorSettings settings,
  }) async {
    state = state.copyWith(input: input, output: output, settings: settings);
  }
}

final historyRepoProvider = Provider<HistoryRepo>((ref) => HistoryRepo());

final editorControllerProvider =
StateNotifierProvider<EditorController, EditorState>(
      (ref) => EditorController(ref.read(historyRepoProvider)),
);
