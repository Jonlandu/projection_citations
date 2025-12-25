import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/widgets/app_scaffold.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return AppScaffold(
      title: t.helpTitle,
      current: AppNav.help,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(t.helpHeader, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(
            t.helpBody,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text(
            t.helpNumberingExamplesTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(t.helpNumberingExamples),
        ],
      ),
    );
  }
}
