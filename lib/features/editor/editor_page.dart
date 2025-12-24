import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  @override
  void dispose() {
    _inputCtrl.dispose();
    _outputCtrl.dispose();
    _maxWordsCtrl.dispose();
    _maxCharsCtrl.dispose();
    _separatorCtrl.dispose();
    _numberFmtCtrl.dispose();
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
    setState(() {});
  }

  String _escapeSeparator(String sep) {
    return sep.replaceAll("\n", r"\n");
  }

  String _unescapeSeparator(String sep) {
    return sep.replaceAll(r"\n", "\n");
  }

  RefactorSettings _buildSettingsFromUI() {
    int? maxWords;
    int? maxChars;

    if (_mode == LimitMode.words) {
      maxWords = int.tryParse(_maxWordsCtrl.text.trim());
    } else if (_mode == LimitMode.chars) {
      maxChars = int.tryParse(_maxCharsCtrl.text.trim());
    }

    final separator = _unescapeSeparator(_separatorCtrl.text);

    return RefactorSettings(
      maxWords: maxWords,
      maxChars: maxChars,
      separator: separator.isEmpty ? "\n\n" : separator,
      ensureEndPunctuation: _ensurePunct,
      autoNumbering: _autoNumber,
      numberingFormat: _numberFmtCtrl.text.isEmpty ? "1) " : _numberFmtCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editorControllerProvider);

    ref.listen(editorControllerProvider, (prev, next) {
      // Keep controllers in sync when loaded from history
      if (prev == null) return;
      if (prev.input != next.input || prev.output != next.output || prev.settings != next.settings) {
        _syncFromState(next);
      }
    });

    return AppScaffold(
      title: "Éditeur",
      current: AppNav.editor,
      child: Shortcuts(
        shortcuts: <ShortcutActivator, Intent>{
          const SingleActivator(LogicalKeyboardKey.enter, control: true): const _ProcessIntent(),
        },
        child: Actions(
          actions: {
            _ProcessIntent: CallbackAction<_ProcessIntent>(onInvoke: (_) async {
              ref.read(editorControllerProvider.notifier).setInput(_inputCtrl.text);
              ref.read(editorControllerProvider.notifier).setSettings(_buildSettingsFromUI());
              await ref.read(editorControllerProvider.notifier).process();
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
                      width: 360,
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
        Text("Paramètres", style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),

        // Mode
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Limite de découpage"),
                const SizedBox(height: 8),
                DropdownButtonFormField<LimitMode>(
                  value: _mode,
                  items: const [
                    DropdownMenuItem(value: LimitMode.none, child: Text("Aucune (respecter les paragraphes)")),
                    DropdownMenuItem(value: LimitMode.words, child: Text("Nombre de mots")),
                    DropdownMenuItem(value: LimitMode.chars, child: Text("Nombre de caractères")),
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
                      labelText: "Max mots par paragraphe",
                      border: OutlineInputBorder(),
                    ),
                  ),
                if (_mode == LimitMode.chars)
                  TextFormField(
                    controller: _maxCharsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Max caractères par paragraphe",
                      border: OutlineInputBorder(),
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Séparateur de paragraphe"),
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
                  title: const Text("Assurer ponctuation en fin de paragraphe"),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

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

        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Raccourci : Ctrl + Entrée pour refactoriser",
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
                onPressed: state.isProcessing
                    ? null
                    : () async {
                  ref.read(editorControllerProvider.notifier).setInput(_inputCtrl.text);
                  ref.read(editorControllerProvider.notifier).setSettings(_buildSettingsFromUI());
                  await ref.read(editorControllerProvider.notifier).process();
                },
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
                "Entrée: ${_inputCtrl.text.length} chars",
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
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Colle ton texte ici…",
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
