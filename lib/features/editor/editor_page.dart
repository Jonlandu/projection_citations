import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  // ✅ NEW: Advanced intelligence / strophe settings
  RefactorMode _refactorMode = RefactorMode.soft;
  bool _smartSplit = true;
  OutputLayoutMode _layoutMode = OutputLayoutMode.stropheLines;
  final _linesPerStropheCtrl = TextEditingController(text: "4");
  final _charsPerLineCtrl = TextEditingController(text: "42");
  LongWordPolicy _longWordPolicy = LongWordPolicy.breakWithHyphen;
  bool _preserveHeaders = true;

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
    });
  }

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

    // display-friendly: allow user to type \n\n
    _separatorCtrl.text = _escapeSeparator(s.separator);

    // ✅ NEW: advanced settings sync
    _refactorMode = s.mode;
    _smartSplit = s.smartSplitLongSentences;
    _layoutMode = s.layoutMode;
    _linesPerStropheCtrl.text = s.linesPerStrophe.toString();
    _charsPerLineCtrl.text = s.charsPerLine.toString();
    _longWordPolicy = s.longWordPolicy;
    _preserveHeaders = s.preserveHeaderLines;

    setState(() {});
  }

  String _escapeSeparator(String sep) => sep.replaceAll("\n", r"\n");
  String _unescapeSeparator(String sep) => sep.replaceAll(r"\n", "\n");

  RefactorSettings _buildSettingsFromUI() {
    int? maxWords;
    int? maxChars;

    if (_mode == LimitMode.words) {
      maxWords = int.tryParse(_maxWordsCtrl.text.trim());
    } else if (_mode == LimitMode.chars) {
      maxChars = int.tryParse(_maxCharsCtrl.text.trim());
    }

    final separator = _unescapeSeparator(_separatorCtrl.text);

    final linesPerStrophe =
        int.tryParse(_linesPerStropheCtrl.text.trim()) ?? 4;
    final charsPerLine = int.tryParse(_charsPerLineCtrl.text.trim()) ?? 42;

    return RefactorSettings(
      maxWords: maxWords,
      maxChars: maxChars,
      separator: separator.isEmpty ? "\n\n" : separator,
      ensureEndPunctuation: _ensurePunct,
      autoNumbering: _autoNumber,
      numberingFormat: _numberFmtCtrl.text.isEmpty ? "1) " : _numberFmtCtrl.text,

      // ✅ NEW
      mode: _refactorMode,
      smartSplitLongSentences: _smartSplit,
      keepSeparatorPunctuation: true,

      // ✅ NEW: strophes / line wrapping
      layoutMode: _layoutMode,
      linesPerStrophe: linesPerStrophe.clamp(1, 20),
      charsPerLine: charsPerLine.clamp(10, 200),
      longWordPolicy: _longWordPolicy,
      preserveHeaderLines: _preserveHeaders,
    );
  }

  Future<void> _runProcess() async {
    ref.read(editorControllerProvider.notifier).setInput(_inputCtrl.text);
    ref.read(editorControllerProvider.notifier).setSettings(_buildSettingsFromUI());
    await ref.read(editorControllerProvider.notifier).process();
  }

  void _insertSeparator() {
    final sep = _unescapeSeparator(_separatorCtrl.text);
    _insertAtCursor(_inputCtrl, sep);
  }

  void _applyPresetBranham() {
    // ✅ One-click preset for your sample formatting
    setState(() {
      _layoutMode = OutputLayoutMode.stropheLines;
      _linesPerStropheCtrl.text = "4";
      _charsPerLineCtrl.text = "28"; // good for "citation" look
      _refactorMode = RefactorMode.soft;
      _smartSplit = true;
      _ensurePunct = true;
      _autoNumber = false;
      _preserveHeaders = true;
      _separatorCtrl.text = r"\n\n";

      // Recommended chunking (optional): 90 words gives nice paragraphs
      _mode = LimitMode.words;
      _maxWordsCtrl.text = "90";
      _maxCharsCtrl.clear();

      _longWordPolicy = LongWordPolicy.breakWithHyphen;
    });
  }

  @override
  Widget build(BuildContext context) {
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
      title: "Éditeur",
      current: AppNav.editor,
      child: Shortcuts(
        shortcuts: <ShortcutActivator, Intent>{
          const SingleActivator(LogicalKeyboardKey.enter, control: true):
          const _ProcessIntent(),
          const SingleActivator(LogicalKeyboardKey.enter, control: true, shift: true):
          const _InsertSepIntent(),
          // ✅ NEW: Ctrl+Alt+B => Apply preset
          const SingleActivator(LogicalKeyboardKey.keyB, control: true, alt: true):
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
            _PresetBranhamIntent: CallbackAction<_PresetBranhamIntent>(onInvoke: (_) {
              _applyPresetBranham();
              return null;
            }),
          },
          child: Focus(
            autofocus: true,
            child: LayoutBuilder(
              builder: (context, c) {
                final isWide = c.maxWidth >= 980;
                return isWide
                    ? Row(
                  children: [
                    SizedBox(
                      width: 380,
                      child: _SettingsPanel(state: state),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: _EditorPanel(state: state)),
                  ],
                )
                    : ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    _SettingsPanel(state: state),
                    const SizedBox(height: 12),
                    _EditorPanel(state: state),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _SettingsPanel({required EditorState state}) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          children: [
            Expanded(
              child: Text("Paramètres", style: Theme.of(context).textTheme.titleLarge),
            ),
            FilledButton.tonalIcon(
              onPressed: _applyPresetBranham,
              icon: const Icon(Icons.auto_awesome),
              label: const Text("Preset Citation"),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // --------- Chunk Limits (words/chars/none)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Limite de découpage (paragraphes)"),
                const SizedBox(height: 8),
                DropdownButtonFormField<LimitMode>(
                  value: _mode,
                  items: const [
                    DropdownMenuItem(
                      value: LimitMode.none,
                      child: Text("Aucune (respecter les paragraphes)"),
                    ),
                    DropdownMenuItem(
                      value: LimitMode.words,
                      child: Text("Nombre de mots"),
                    ),
                    DropdownMenuItem(
                      value: LimitMode.chars,
                      child: Text("Nombre de caractères"),
                    ),
                  ],
                  onChanged: (v) {
                    setState(() => _mode = v ?? LimitMode.none);
                  },
                ),
                const SizedBox(height: 10),
                if (_mode == LimitMode.words)
                  TextFormField(
                    controller: _maxWordsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Max mots par paragraphe (ex: 90)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                if (_mode == LimitMode.chars)
                  TextFormField(
                    controller: _maxCharsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Max caractères par paragraphe (ex: 650)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  "Astuce: si un texte a des phrases très longues, active le mode intelligent ci-dessous.",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // --------- Refactor intelligence
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Refactorisation intelligente"),
                const SizedBox(height: 8),
                DropdownButtonFormField<RefactorMode>(
                  value: _refactorMode,
                  items: const [
                    DropdownMenuItem(
                      value: RefactorMode.soft,
                      child: Text("Doux (style naturel)"),
                    ),
                    DropdownMenuItem(
                      value: RefactorMode.strict,
                      child: Text("Strict (plus structuré)"),
                    ),
                    DropdownMenuItem(
                      value: RefactorMode.aggressive,
                      child: Text("Agressif (coupe davantage)"),
                    ),
                  ],
                  onChanged: (v) =>
                      setState(() => _refactorMode = v ?? RefactorMode.soft),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Mode",
                  ),
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _smartSplit,
                  onChanged: (v) => setState(() => _smartSplit = v),
                  title: const Text("Découper les pensées longues intelligemment"),
                  subtitle: const Text("Phrase → ; : , → mots (fallback)"),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // --------- Separator / punctuation
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Séparateur de paragraphe / strophe"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _separatorCtrl,
                  decoration: const InputDecoration(
                    hintText: r"Ex: \n\n ou ----",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _ensurePunct,
                  onChanged: (v) => setState(() => _ensurePunct = v),
                  title: const Text("Assurer ponctuation en fin de bloc"),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // --------- Output Layout: strophes/lines
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Strophes & lignes (comme ton exemple)"),
                const SizedBox(height: 8),
                DropdownButtonFormField<OutputLayoutMode>(
                  value: _layoutMode,
                  items: const [
                    DropdownMenuItem(
                      value: OutputLayoutMode.paragraph,
                      child: Text("Paragraphes classiques"),
                    ),
                    DropdownMenuItem(
                      value: OutputLayoutMode.stropheLines,
                      child: Text("Strophes (lignes)"),
                    ),
                  ],
                  onChanged: (v) => setState(() =>
                  _layoutMode = v ?? OutputLayoutMode.stropheLines),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Format final",
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _linesPerStropheCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Lignes / strophe (ex: 4)",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _charsPerLineCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Largeur ligne (chars) (ex: 28)",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<LongWordPolicy>(
                  value: _longWordPolicy,
                  items: const [
                    DropdownMenuItem(
                      value: LongWordPolicy.breakWithHyphen,
                      child: Text("Mot long: découper avec '-'"),
                    ),
                    DropdownMenuItem(
                      value: LongWordPolicy.hardBreak,
                      child: Text("Mot long: découper sans '-'"),
                    ),
                    DropdownMenuItem(
                      value: LongWordPolicy.overflow,
                      child: Text("Mot long: ne pas couper (overflow)"),
                    ),
                  ],
                  onChanged: (v) => setState(() =>
                  _longWordPolicy = v ?? LongWordPolicy.breakWithHyphen),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Mots très longs",
                  ),
                ),
                const SizedBox(height: 10),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _preserveHeaders,
                  onChanged: (v) => setState(() => _preserveHeaders = v),
                  title: const Text("Préserver les titres (*...*, §..., dates…)"),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // --------- Numbering
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
                  title: const Text("Numérotation automatique"),
                ),
                const SizedBox(height: 8),
                if (_autoNumber)
                  TextFormField(
                    controller: _numberFmtCtrl,
                    decoration: const InputDecoration(
                      labelText: "Format (ex: 1)  |  1.  |  [1] )",
                      border: OutlineInputBorder(),
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // --------- Shortcuts / reset
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Raccourcis :\n"
                      "• Ctrl + Entrée : Refactoriser\n"
                      "• Ctrl + Shift + Entrée : Insérer séparateur\n"
                      "• Ctrl + Alt + B : Preset Citation",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    ref.read(editorControllerProvider.notifier).clearAll();
                    _syncFromState(ref.read(editorControllerProvider));
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text("Réinitialiser"),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _EditorPanel({required EditorState state}) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
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
                label: Text(state.isProcessing ? "Traitement..." : "Refactoriser"),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: _insertSeparator,
                icon: const Icon(Icons.vertical_split),
                label: const Text("Insérer séparateur"),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () async {
                  final text = _outputCtrl.text.trim();
                  if (text.isEmpty) return;
                  await Clipboard.setData(ClipboardData(text: text));
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Texte copié !")),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text("Copier résultat"),
              ),
              const Spacer(),
              Text(
                "Entrée: ${_inputCtrl.text.length} chars  •  Sortie: ${_outputCtrl.text.length} chars",
                style: Theme.of(context).textTheme.bodySmall,
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
                    title: "Texte brut",
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
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText:
                        "Colle ton texte ici… (double Entrée = séparateur)",
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TextCard(
                    title: "Texte généré",
                    child: TextField(
                      controller: _outputCtrl,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Le résultat apparaîtra ici… (modifiable)",
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
