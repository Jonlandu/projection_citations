import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/widgets/paragraph_separator_input_formatter.dart';
import '../../shared/widgets/app_scaffold.dart';
import 'editor_controller.dart';
import 'models.dart';

class EditorPage extends ConsumerStatefulWidget {
  const EditorPage({super.key});

  @override
  ConsumerState<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends ConsumerState<EditorPage> {
  final _inputCtrl = TextEditingController();
  final _outputCtrl = TextEditingController();

  LimitMode _mode = LimitMode.none;
  final _maxWordsCtrl = TextEditingController();
  final _maxCharsCtrl = TextEditingController();

  final _separatorCtrl = TextEditingController(text: r"\n\n");
  bool _ensurePunct = true;
  bool _autoNumber = false;
  final _numberFmtCtrl = TextEditingController(text: "1) ");

  // Advanced intelligence / strophe settings
  RefactorMode _refactorMode = RefactorMode.soft;
  bool _smartSplit = true;

  OutputLayoutMode _layoutMode = OutputLayoutMode.stropheLines;
  final _linesPerStropheCtrl = TextEditingController(text: "4");
  final _charsPerLineCtrl = TextEditingController(text: "42");

  LongWordPolicy _longWordPolicy = LongWordPolicy.breakWithHyphen;
  bool _preserveHeaders = true;

  // smart strophe breaks
  bool _smartStrophes = true;

  // Auto calculate charsPerLine based on real width
  final GlobalKey _resultKey = GlobalKey();
  bool _autoCharsPerLine = true;
  double _lastMeasuredWidth = 0;

  @override
  void dispose() {
    _inputCtrl.dispose();
    _outputCtrl.dispose();
    _maxWordsCtrl.dispose();
    _maxCharsCtrl.dispose();
    _separatorCtrl.dispose();
    _numberFmtCtrl.dispose();
    _linesPerStropheCtrl.dispose();
    _charsPerLineCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final st = ref.read(editorControllerProvider);
      _syncFromState(st);

      WidgetsBinding.instance.addPostFrameCallback((__) {
        _maybeAutoUpdateCharsPerLine(context);
      });
    });
  }

  // -----------------------------
  // Auto chars-per-line measure
  // -----------------------------
  int _estimateCharsPerLine(BuildContext context, double maxWidth) {
    final style =
        Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14);

    const sample = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    final tp = TextPainter(
      text: TextSpan(text: sample, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    final avgCharWidth = tp.width / sample.length;
    if (avgCharWidth <= 0) return 42;

    final usable = (maxWidth - 32).clamp(120, 2000);
    final chars = (usable / avgCharWidth).floor();
    return chars.clamp(10, 200);
  }

  void _maybeAutoUpdateCharsPerLine(BuildContext context) {
    if (!_autoCharsPerLine) return;

    final render = _resultKey.currentContext?.findRenderObject();
    if (render is! RenderBox) return;

    final w = render.size.width;
    if (w <= 0) return;

    if ((w - _lastMeasuredWidth).abs() < 12) return;
    _lastMeasuredWidth = w;

    final est = _estimateCharsPerLine(context, w);
    if (_charsPerLineCtrl.text.trim() != est.toString()) {
      _charsPerLineCtrl.text = est.toString();
      setState(() {});
    }
  }

  // -----------------------------
  // Cursor insert helper
  // -----------------------------
  void _insertAtCursor(TextEditingController controller, String toInsert) {
    final value = controller.value;
    final text = value.text;
    final selection = value.selection;

    final start = selection.start < 0 ? text.length : selection.start;
    final end = selection.end < 0 ? text.length : selection.end;

    final newText = text.replaceRange(start, end, toInsert);
    final newOffset = start + toInsert.length;

    controller.value = value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newOffset),
      composing: TextRange.empty,
    );
  }

  // -----------------------------
  // Sync with state
  // -----------------------------
  void _syncFromState(EditorState st) {
    _inputCtrl.text = st.input;
    _outputCtrl.text = st.output;

    final s = st.settings;
    if (s.maxWords != null) {
      _mode = LimitMode.words;
      _maxWordsCtrl.text = s.maxWords.toString();
      _maxCharsCtrl.clear();
    } else if (s.maxChars != null) {
      _mode = LimitMode.chars;
      _maxCharsCtrl.text = s.maxChars.toString();
      _maxWordsCtrl.clear();
    } else {
      _mode = LimitMode.none;
      _maxWordsCtrl.clear();
      _maxCharsCtrl.clear();
    }

    _ensurePunct = s.ensureEndPunctuation;
    _autoNumber = s.autoNumbering;
    _numberFmtCtrl.text = s.numberingFormat;

    _separatorCtrl.text = _escapeSeparator(s.separator);

    _refactorMode = s.mode;
    _smartSplit = s.smartSplitLongSentences;

    _layoutMode = s.layoutMode;
    _linesPerStropheCtrl.text = s.linesPerStrophe.toString();
    _charsPerLineCtrl.text = s.charsPerLine.toString();

    _longWordPolicy = s.longWordPolicy;
    _preserveHeaders = s.preserveHeaderLines;

    _smartStrophes = s.smartStropheBreaks;

    setState(() {});
  }

  String _escapeSeparator(String sep) => sep.replaceAll("\n", r"\n");
  String _unescapeSeparator(String sep) => sep.replaceAll(r"\n", "\n");

  // -----------------------------
  // Build settings
  // -----------------------------
  RefactorSettings _buildSettingsFromUI() {
    int? maxWords;
    int? maxChars;

    if (_mode == LimitMode.words) {
      maxWords = int.tryParse(_maxWordsCtrl.text.trim());
    } else if (_mode == LimitMode.chars) {
      maxChars = int.tryParse(_maxCharsCtrl.text.trim());
    }

    final separator = _unescapeSeparator(_separatorCtrl.text);

    final linesPerStrophe = int.tryParse(_linesPerStropheCtrl.text.trim()) ?? 4;
    final charsPerLine = int.tryParse(_charsPerLineCtrl.text.trim()) ?? 42;

    return RefactorSettings(
      maxWords: maxWords,
      maxChars: maxChars,
      separator: separator.isEmpty ? "\n\n" : separator,
      ensureEndPunctuation: _ensurePunct,
      autoNumbering: _autoNumber,
      numberingFormat: _numberFmtCtrl.text.isEmpty ? "1) " : _numberFmtCtrl.text,
      mode: _refactorMode,
      smartSplitLongSentences: _smartSplit,
      keepSeparatorPunctuation: true,
      layoutMode: _layoutMode,
      linesPerStrophe: linesPerStrophe.clamp(1, 20),
      charsPerLine: charsPerLine.clamp(10, 200),
      longWordPolicy: _longWordPolicy,
      preserveHeaderLines: _preserveHeaders,
      smartStropheBreaks: _smartStrophes,
    );
  }

  Future<void> _runProcess() async {
    ref.read(editorControllerProvider.notifier).setInput(_inputCtrl.text);
    ref
        .read(editorControllerProvider.notifier)
        .setSettings(_buildSettingsFromUI());
    await ref.read(editorControllerProvider.notifier).process();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeAutoUpdateCharsPerLine(context);
    });
  }

  void _insertSeparator() {
    final sep = _unescapeSeparator(_separatorCtrl.text);
    _insertAtCursor(_inputCtrl, sep);
  }

  void _applyPresetBranham() {
    setState(() {
      _layoutMode = OutputLayoutMode.stropheLines;
      _linesPerStropheCtrl.text = "4";

      _autoCharsPerLine = true;
      _charsPerLineCtrl.text = "28";

      _refactorMode = RefactorMode.soft;
      _smartSplit = true;

      _ensurePunct = true;
      _autoNumber = false;

      _preserveHeaders = true;
      _smartStrophes = true;

      _separatorCtrl.text = r"\n\n";

      _mode = LimitMode.words;
      _maxWordsCtrl.text = "90";
      _maxCharsCtrl.clear();

      _longWordPolicy = LongWordPolicy.breakWithHyphen;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeAutoUpdateCharsPerLine(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // ✅ non-null
    final state = ref.watch(editorControllerProvider);

    ref.listen(editorControllerProvider, (prev, next) {
      if (prev == null) return;
      if (prev.input != next.input ||
          prev.output != next.output ||
          prev.settings != next.settings) {
        _syncFromState(next);
      }
    });

    return AppScaffold(
      title: l10n.editorTitle,
      current: AppNav.editor,
      child: Shortcuts(
        shortcuts: <ShortcutActivator, Intent>{
          const SingleActivator(LogicalKeyboardKey.enter, control: true):
          const _ProcessIntent(),
          const SingleActivator(LogicalKeyboardKey.enter,
              control: true, shift: true):
          const _InsertSepIntent(),
          const SingleActivator(LogicalKeyboardKey.keyB,
              control: true, alt: true):
          const _PresetBranhamIntent(),
        },
        child: Actions(
          actions: {
            _ProcessIntent: CallbackAction<_ProcessIntent>(onInvoke: (_) async {
              await _runProcess();
              return null;
            }),
            _InsertSepIntent: CallbackAction<_InsertSepIntent>(onInvoke: (_) {
              _insertSeparator();
              return null;
            }),
            _PresetBranhamIntent:
            CallbackAction<_PresetBranhamIntent>(onInvoke: (_) {
              _applyPresetBranham();
              return null;
            }),
          },
          child: Focus(
            autofocus: true,
            child: LayoutBuilder(
              builder: (context, c) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _maybeAutoUpdateCharsPerLine(context);
                });

                final isWide = c.maxWidth >= 980;
                return isWide
                    ? Row(
                  children: [
                    SizedBox(
                      width: 400,
                      child: _SettingsPanel(state: state, l10n: l10n),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: _EditorPanel(state: state, l10n: l10n)),
                  ],
                )
                    : ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    _SettingsPanel(state: state, l10n: l10n),
                    const SizedBox(height: 12),
                    _EditorPanel(state: state, l10n: l10n),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _SettingsPanel({required EditorState state, required AppLocalizations l10n}) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.settingsTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: _applyPresetBranham,
              icon: const Icon(Icons.auto_awesome),
              label: Text(l10n.presetCitation),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Chunk Limits
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.chunkLimitTitle),
                const SizedBox(height: 8),
                DropdownButtonFormField<LimitMode>(
                  value: _mode,
                  items: [
                    DropdownMenuItem(
                      value: LimitMode.none,
                      child: Text(l10n.limitNone),
                    ),
                    DropdownMenuItem(
                      value: LimitMode.words,
                      child: Text(l10n.limitWords),
                    ),
                    DropdownMenuItem(
                      value: LimitMode.chars,
                      child: Text(l10n.limitChars),
                    ),
                  ],
                  onChanged: (v) => setState(() => _mode = v ?? LimitMode.none),
                ),
                const SizedBox(height: 10),
                if (_mode == LimitMode.words)
                  TextFormField(
                    controller: _maxWordsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.maxWordsLabel,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                if (_mode == LimitMode.chars)
                  TextFormField(
                    controller: _maxCharsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.maxCharsLabel,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  l10n.chunkTip,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Refactor intelligence
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.smartRefactorTitle),
                const SizedBox(height: 8),
                DropdownButtonFormField<RefactorMode>(
                  value: _refactorMode,
                  items: [
                    DropdownMenuItem(
                      value: RefactorMode.soft,
                      child: Text(l10n.modeSoft),
                    ),
                    DropdownMenuItem(
                      value: RefactorMode.strict,
                      child: Text(l10n.modeStrict),
                    ),
                    DropdownMenuItem(
                      value: RefactorMode.aggressive,
                      child: Text(l10n.modeAggressive),
                    ),
                  ],
                  onChanged: (v) =>
                      setState(() => _refactorMode = v ?? RefactorMode.soft),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: l10n.modeLabel,
                  ),
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _smartSplit,
                  onChanged: (v) => setState(() => _smartSplit = v),
                  title: Text(l10n.smartSplitTitle),
                  subtitle: Text(l10n.smartSplitSubtitle),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Separator / punctuation
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.separatorTitle),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _separatorCtrl,
                  decoration: InputDecoration(
                    hintText: l10n.separatorHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _ensurePunct,
                  onChanged: (v) => setState(() => _ensurePunct = v),
                  title: Text(l10n.ensurePunctTitle),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Output layout
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.strophesTitle),
                const SizedBox(height: 8),
                DropdownButtonFormField<OutputLayoutMode>(
                  value: _layoutMode,
                  items: [
                    DropdownMenuItem(
                      value: OutputLayoutMode.paragraph,
                      child: Text(l10n.formatParagraph),
                    ),
                    DropdownMenuItem(
                      value: OutputLayoutMode.stropheLines,
                      child: Text(l10n.formatStropheLines),
                    ),
                  ],
                  onChanged: (v) => setState(
                          () => _layoutMode = v ?? OutputLayoutMode.stropheLines),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: l10n.outputFormatLabel,
                  ),
                ),
                const SizedBox(height: 10),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _autoCharsPerLine,
                  onChanged: (v) {
                    setState(() => _autoCharsPerLine = v);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _maybeAutoUpdateCharsPerLine(context);
                    });
                  },
                  title: Text(l10n.autoLineWidthTitle),
                  subtitle: Text(l10n.autoLineWidthSubtitle),
                ),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _linesPerStropheCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.linesPerStropheLabel,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _charsPerLineCtrl,
                        enabled: !_autoCharsPerLine,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.charsPerLineLabel,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                DropdownButtonFormField<LongWordPolicy>(
                  value: _longWordPolicy,
                  items: [
                    DropdownMenuItem(
                      value: LongWordPolicy.breakWithHyphen,
                      child: Text(l10n.longWordHyphen),
                    ),
                    DropdownMenuItem(
                      value: LongWordPolicy.hardBreak,
                      child: Text(l10n.longWordHard),
                    ),
                    DropdownMenuItem(
                      value: LongWordPolicy.overflow,
                      child: Text(l10n.longWordOverflow),
                    ),
                  ],
                  onChanged: (v) => setState(() =>
                  _longWordPolicy = v ?? LongWordPolicy.breakWithHyphen),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: l10n.longWordsLabel,
                  ),
                ),
                const SizedBox(height: 10),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _preserveHeaders,
                  onChanged: (v) => setState(() => _preserveHeaders = v),
                  title: Text(l10n.preserveHeadersTitle),
                ),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _smartStrophes,
                  onChanged: (v) => setState(() => _smartStrophes = v),
                  title: Text(l10n.smartStrophesTitle),
                  subtitle: Text(l10n.smartStrophesSubtitle),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Numbering
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _autoNumber,
                  onChanged: (v) => setState(() => _autoNumber = v),
                  title: Text(l10n.numberingTitle),
                ),
                const SizedBox(height: 8),
                if (_autoNumber)
                  TextFormField(
                    controller: _numberFmtCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.numberingFormatLabel,
                      border: const OutlineInputBorder(),
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Shortcuts / reset
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${l10n.shortcutsTitle}\n"
                      "${l10n.shortcutProcess}\n"
                      "${l10n.shortcutInsertSep}\n"
                      "${l10n.shortcutPreset}",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    ref.read(editorControllerProvider.notifier).clearAll();
                    _syncFromState(ref.read(editorControllerProvider));
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l10n.reset),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _EditorPanel({required EditorState state, required AppLocalizations l10n}) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: state.isProcessing ? null : _runProcess,
                icon: state.isProcessing
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.auto_fix_high),
                label: Text(state.isProcessing ? l10n.processing : l10n.refactor),
              ),
              OutlinedButton.icon(
                onPressed: _insertSeparator,
                icon: const Icon(Icons.vertical_split),
                label: Text(l10n.insertSeparator),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final text = _outputCtrl.text.trim();
                  if (text.isEmpty) return;
                  await Clipboard.setData(ClipboardData(text: text));
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.copied)),
                  );
                },
                icon: const Icon(Icons.copy),
                label: Text(l10n.copyResult),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Text(
                  l10n.stats(
                    _inputCtrl.text.length.toString(),
                    _outputCtrl.text.length.toString(),
                  ),
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
          if (state.error != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                state.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _TextCard(
                    title: l10n.rawTextTitle,
                    child: TextField(
                      controller: _inputCtrl,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      inputFormatters: [
                        ParagraphSeparatorInputFormatter(
                          separator: _unescapeSeparator(_separatorCtrl.text),
                        ),
                      ],
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: l10n.rawHint,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    key: _resultKey,
                    child: _TextCard(
                      title: l10n.generatedTextTitle,
                      child: TextField(
                        controller: _outputCtrl,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: l10n.generatedHint,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TextCard extends StatelessWidget {
  const _TextCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Expanded(child: child),
      ],
    );
  }
}

class _ProcessIntent extends Intent {
  const _ProcessIntent();
}

class _InsertSepIntent extends Intent {
  const _InsertSepIntent();
}

class _PresetBranhamIntent extends Intent {
  const _PresetBranhamIntent();
}
