// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'ProjectionCitations';

  @override
  String get welcomeTitle => 'Bienvenue';

  @override
  String get welcomeSubtitle =>
      'Application hors ligne de refactorisation et mise en forme intelligente de texte.';

  @override
  String get welcomeBullets =>
      '• Colle un texte brut\n• Configure le découpage (mots / caractères)\n• Génère un texte propre et structuré\n• Copie sans obligation d’enregistrement\n';

  @override
  String get start => 'Commencer';

  @override
  String get language => 'Langue';

  @override
  String get systemLanguage => 'Langue du système';

  @override
  String get french => 'Français';

  @override
  String get english => 'English';

  @override
  String get portuguese => 'Português';

  @override
  String get helpTitle => 'Aide';

  @override
  String get helpHeader => 'Aide & Guide';

  @override
  String get helpBody =>
      '1) Colle ton texte brut dans la zone \'Texte brut\'.\n2) Configure les paramètres (mots, caractères, séparateur, ponctuation, numérotation).\n3) Clique sur \'Refactoriser\' (ou Ctrl + Entrée).\n4) Tu peux modifier le texte généré.\n5) Clique sur \'Copier résultat\' pour copier.\n\nConseils:\n- Si tu veux garder les paragraphes existants : mets \'Aucune\' dans la limite.\n- Pour créer des paragraphes équilibrés : utilise \'Nombre de mots\' (ex: 60–120).\n- Le séparateur accepte \\n pour retour ligne (ex: \\n\\n).';

  @override
  String get helpNumberingExamplesTitle => 'Exemples de format de numérotation';

  @override
  String get helpNumberingExamples => '- 1) \n- 1. \n- [1] \n';

  @override
  String get historyTitle => 'Historique';

  @override
  String get historyEmpty => 'Aucun historique pour le moment.';

  @override
  String get deleteAll => 'Tout supprimer';

  @override
  String get historyCleared => 'Historique supprimé';

  @override
  String get entryDeleted => 'Entrée supprimée';

  @override
  String get undo => 'ANNULER';

  @override
  String get delete => 'Supprimer';

  @override
  String historyItemSubtitle(Object date, Object count) {
    return 'Le $date • $count chars';
  }

  @override
  String get editorTitle => 'Éditeur';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get presetCitation => 'Preset Citation';

  @override
  String get chunkLimitTitle => 'Limite de découpage (paragraphes)';

  @override
  String get limitNone => 'Aucune (respecter les paragraphes)';

  @override
  String get limitWords => 'Nombre de mots';

  @override
  String get limitChars => 'Nombre de caractères';

  @override
  String get maxWordsLabel => 'Max mots par paragraphe (ex: 90)';

  @override
  String get maxCharsLabel => 'Max caractères par paragraphe (ex: 650)';

  @override
  String get chunkTip =>
      'Astuce: active le mode intelligent si les phrases sont très longues.';

  @override
  String get smartRefactorTitle => 'Refactorisation intelligente';

  @override
  String get modeLabel => 'Mode';

  @override
  String get modeSoft => 'Doux (style naturel)';

  @override
  String get modeStrict => 'Strict (plus structuré)';

  @override
  String get modeAggressive => 'Agressif (coupe davantage)';

  @override
  String get smartSplitTitle => 'Découper les pensées longues intelligemment';

  @override
  String get smartSplitSubtitle => 'Phrase → ; : , → mots (fallback)';

  @override
  String get separatorTitle => 'Séparateur de paragraphe / strophe';

  @override
  String get separatorHint => 'Ex: \\n\\n ou ----';

  @override
  String get ensurePunctTitle => 'Assurer ponctuation en fin de bloc';

  @override
  String get strophesTitle => 'Strophes & lignes (comme ton exemple)';

  @override
  String get outputFormatLabel => 'Format final';

  @override
  String get formatParagraph => 'Paragraphes classiques';

  @override
  String get formatStropheLines => 'Strophes (lignes)';

  @override
  String get autoLineWidthTitle => 'Auto: largeur de ligne selon la fenêtre';

  @override
  String get autoLineWidthSubtitle =>
      'Mesure la zone résultat et ajuste chars/ligne';

  @override
  String get linesPerStropheLabel => 'Lignes / strophe (ex: 4)';

  @override
  String get charsPerLineLabel => 'Largeur ligne (chars)';

  @override
  String get longWordsLabel => 'Mots très longs';

  @override
  String get longWordHyphen => 'Mot long: découper avec \'-\'';

  @override
  String get longWordHard => 'Mot long: découper sans \'-\'';

  @override
  String get longWordOverflow => 'Mot long: ne pas couper (overflow)';

  @override
  String get preserveHeadersTitle =>
      'Préserver les titres (*...*, §..., dates…)';

  @override
  String get smartStrophesTitle => 'Strophes intelligentes (fin de phrase)';

  @override
  String get smartStrophesSubtitle =>
      'Ferme une strophe sur une phrase complète quand c’est pertinent';

  @override
  String get numberingTitle => 'Numérotation automatique';

  @override
  String get numberingFormatLabel => 'Format (ex: 1)  |  1.  |  [1] )';

  @override
  String get shortcutsTitle => 'Raccourcis :';

  @override
  String get shortcutProcess => '• Ctrl + Entrée : Refactoriser';

  @override
  String get shortcutInsertSep =>
      '• Ctrl + Shift + Entrée : Insérer séparateur';

  @override
  String get shortcutPreset => '• Ctrl + Alt + B : Preset Citation';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get processing => 'Traitement...';

  @override
  String get refactor => 'Refactoriser';

  @override
  String get insertSeparator => 'Insérer séparateur';

  @override
  String get copyResult => 'Copier résultat';

  @override
  String get copied => 'Texte copié !';

  @override
  String get rawTextTitle => 'Texte brut';

  @override
  String get generatedTextTitle => 'Texte généré';

  @override
  String get rawHint => 'Colle ton texte ici… (double Entrée = séparateur)';

  @override
  String get generatedHint => 'Le résultat apparaîtra ici… (modifiable)';

  @override
  String stats(Object inChars, Object outChars) {
    return 'Entrée: $inChars chars  •  Sortie: $outChars chars';
  }
}
