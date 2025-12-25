import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/locale_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../editor/editor_page.dart';

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeControllerProvider);

    return AppScaffold(
      title: t.welcomeTitle,
      current: AppNav.welcome,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(22),
                    child: ConstrainedBox(
                      // ✅ garantit un minimum de hauteur, mais autorise le scroll si ça dépasse
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.appTitle,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              t.welcomeSubtitle,
                              style: Theme.of(context).textTheme.bodyLarge,
                              softWrap: true,
                            ),
                            const SizedBox(height: 16),

                            // ✅ Dropdown: prend toute la largeur, évite overflow à droite
                            SizedBox(
                              width: double.infinity,
                              child: DropdownButtonFormField<Locale?>(
                                value: currentLocale,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: t.language,
                                  border: const OutlineInputBorder(),
                                ),
                                items: [
                                  DropdownMenuItem<Locale?>(
                                    value: null,
                                    child: Text(t.systemLanguage),
                                  ),
                                  DropdownMenuItem<Locale?>(
                                    value: const Locale('fr'),
                                    child: Text(t.french),
                                  ),
                                  DropdownMenuItem<Locale?>(
                                    value: const Locale('en'),
                                    child: Text(t.english),
                                  ),
                                  DropdownMenuItem<Locale?>(
                                    value: const Locale('pt'),
                                    child: Text(t.portuguese),
                                  ),
                                ],
                                onChanged: (v) {
                                  ref
                                      .read(localeControllerProvider.notifier)
                                      .setLocale(v);
                                },
                              ),
                            ),

                            const SizedBox(height: 16),
                            Text(
                              t.welcomeBullets,
                              softWrap: true,
                            ),

                            const Spacer(),

                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => const EditorPage(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.arrow_forward),
                                label: Text(t.start),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
