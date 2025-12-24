import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/formatters.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../editor/editor_controller.dart';
import '../editor/editor_page.dart';
import 'history_repo.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(historyRepoProvider);
    final items = repo.getAll();

    return AppScaffold(
      title: "Historique",
      current: AppNav.history,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Text("Historique", style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: items.isEmpty
                      ? null
                      : () async {
                    await repo.clearAll();
                    (context as Element).markNeedsBuild();
                  },
                  icon: const Icon(Icons.delete_sweep),
                  label: const Text("Tout supprimer"),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text("Aucun historique pour le moment."))
                  : ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final e = items[i];
                  return ListTile(
                    title: Text(shortPreview(e.output)),
                    subtitle: Text(
                      "Le ${e.createdAt.toLocal()} • ${e.output.length} chars",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      tooltip: "Supprimer",
                      onPressed: () async {
                        await repo.deleteEntry(e);
                        (context as Element).markNeedsBuild();
                      },
                      icon: const Icon(Icons.delete_outline),
                    ),
                    onTap: () async {
                      await ref.read(editorControllerProvider.notifier).loadFromHistory(
                        input: e.input,
                        output: e.output,
                        settings: e.settings,
                      );
                      if (context.mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const EditorPage()),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
