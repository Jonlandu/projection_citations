import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/formatters.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../editor/editor_controller.dart';
import '../editor/editor_page.dart';
import 'history_repo.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;

    final repo = ref.read(historyRepoProvider);
    final box = Hive.box<HistoryEntry>(AppConstants.historyBoxName);

    return AppScaffold(
      title: t.historyTitle,
      current: AppNav.history,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ValueListenableBuilder<Box<HistoryEntry>>(
          valueListenable: box.listenable(),
          builder: (context, b, _) {
            final items = b.values.toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            final header = Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  t.historyTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
                OutlinedButton.icon(
                  onPressed: items.isEmpty
                      ? null
                      : () async {
                    await repo.clearAll();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(t.historyCleared)),
                    );
                  },
                  icon: const Icon(Icons.delete_sweep),
                  label: Text(
                    t.deleteAll,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );

            if (items.isEmpty) {
              return ListView(
                children: [
                  header,
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(top: 48),
                    child: Center(child: Text(t.historyEmpty)),
                  ),
                ],
              );
            }

            return ListView.separated(
              itemCount: items.length + 1, // header + items
              separatorBuilder: (_, index) {
                if (index == 0) return const SizedBox(height: 12);
                return const Divider(height: 1);
              },
              itemBuilder: (context, index) {
                if (index == 0) return header;

                final e = items[index - 1];
                final hiveKey = e.key; // IMPORTANT: avant delete()

                return Dismissible(
                  key: ValueKey(hiveKey),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) async {
                    final snapshot = HistoryEntry(
                      input: e.input,
                      output: e.output,
                      settingsJson: e.settingsJson,
                      createdAt: e.createdAt,
                    );

                    await repo.deleteEntry(e);

                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(t.entryDeleted),
                        action: SnackBarAction(
                          label: t.undo,
                          onPressed: () async {
                            await repo.restoreAtKey(hiveKey, snapshot);
                          },
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    title: Text(shortPreview(e.output)),
                    subtitle: Text(
                      t.historyItemSubtitle(
                        e.createdAt.toLocal().toString(),
                        e.output.length,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      tooltip: t.delete,
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        final snapshot = HistoryEntry(
                          input: e.input,
                          output: e.output,
                          settingsJson: e.settingsJson,
                          createdAt: e.createdAt,
                        );

                        await repo.deleteEntry(e);

                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(t.entryDeleted),
                            action: SnackBarAction(
                              label: t.undo,
                              onPressed: () async {
                                await repo.restoreAtKey(hiveKey, snapshot);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    onTap: () async {
                      await ref
                          .read(editorControllerProvider.notifier)
                          .loadFromHistory(
                        input: e.input,
                        output: e.output,
                        settings: e.settings,
                      );

                      if (!context.mounted) return;
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const EditorPage(),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
