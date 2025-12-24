import 'package:flutter/material.dart';

import '../../shared/widgets/app_scaffold.dart';
import '../editor/editor_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Bienvenue",
      current: AppNav.welcome,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("ProjectionCitations", style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      "Application hors ligne de refactorisation et mise en forme intelligente de texte.",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "• Colle un texte brut\n"
                          "• Configure le découpage (mots / caractères)\n"
                          "• Génère un texte propre et structuré\n"
                          "• Copie sans obligation d’enregistrement\n",
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const EditorPage()),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text("Commencer"),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
