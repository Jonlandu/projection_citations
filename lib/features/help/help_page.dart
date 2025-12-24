import 'package:flutter/material.dart';
import '../../shared/widgets/app_scaffold.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Aide",
      current: AppNav.help,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text("Aide & Guide", style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          const Text(
            "1) Colle ton texte brut dans la zone 'Texte brut'.\n"
                "2) Configure les paramètres à gauche (mots, caractères, séparateur, ponctuation, numérotation).\n"
                "3) Clique sur 'Refactoriser' (ou Ctrl + Entrée).\n"
                "4) Tu peux modifier le texte généré.\n"
                "5) Clique sur 'Copier résultat' pour copier.\n\n"
                "Conseils:\n"
                "- Si tu veux garder les paragraphes existants : mets 'Aucune' dans la limite.\n"
                "- Pour créer des paragraphes équilibrés : utilise 'Nombre de mots' (ex: 60–120).\n"
                "- Le séparateur accepte \\n pour retour ligne (ex: \\n\\n).",
          ),
          const SizedBox(height: 16),
          Text("Exemples de format de numérotation", style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const Text(
            "- 1) \n"
                "- 1. \n"
                "- [1] \n",
          ),
        ],
      ),
    );
  }
}
