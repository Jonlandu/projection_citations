import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'ProjectionCitations'**
  String get appTitle;

  /// No description provided for @welcomeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Application hors ligne de refactorisation et mise en forme intelligente de texte.'**
  String get welcomeSubtitle;

  /// No description provided for @welcomeBullets.
  ///
  /// In fr, this message translates to:
  /// **'• Colle un texte brut\n• Configure le découpage (mots / caractères)\n• Génère un texte propre et structuré\n• Copie sans obligation d’enregistrement\n'**
  String get welcomeBullets;

  /// No description provided for @start.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get start;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @systemLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue du système'**
  String get systemLanguage;

  /// No description provided for @french.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @english.
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @portuguese.
  ///
  /// In fr, this message translates to:
  /// **'Português'**
  String get portuguese;

  /// No description provided for @helpTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aide'**
  String get helpTitle;

  /// No description provided for @helpHeader.
  ///
  /// In fr, this message translates to:
  /// **'Aide & Guide'**
  String get helpHeader;

  /// No description provided for @helpBody.
  ///
  /// In fr, this message translates to:
  /// **'1) Colle ton texte brut dans la zone \'Texte brut\'.\n2) Configure les paramètres (mots, caractères, séparateur, ponctuation, numérotation).\n3) Clique sur \'Refactoriser\' (ou Ctrl + Entrée).\n4) Tu peux modifier le texte généré.\n5) Clique sur \'Copier résultat\' pour copier.\n\nConseils:\n- Si tu veux garder les paragraphes existants : mets \'Aucune\' dans la limite.\n- Pour créer des paragraphes équilibrés : utilise \'Nombre de mots\' (ex: 60–120).\n- Le séparateur accepte \\n pour retour ligne (ex: \\n\\n).'**
  String get helpBody;

  /// No description provided for @helpNumberingExamplesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Exemples de format de numérotation'**
  String get helpNumberingExamplesTitle;

  /// No description provided for @helpNumberingExamples.
  ///
  /// In fr, this message translates to:
  /// **'- 1) \n- 1. \n- [1] \n'**
  String get helpNumberingExamples;

  /// No description provided for @historyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get historyTitle;

  /// No description provided for @historyEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun historique pour le moment.'**
  String get historyEmpty;

  /// No description provided for @deleteAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout supprimer'**
  String get deleteAll;

  /// No description provided for @historyCleared.
  ///
  /// In fr, this message translates to:
  /// **'Historique supprimé'**
  String get historyCleared;

  /// No description provided for @entryDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Entrée supprimée'**
  String get entryDeleted;

  /// No description provided for @undo.
  ///
  /// In fr, this message translates to:
  /// **'ANNULER'**
  String get undo;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @historyItemSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Le {date} • {count} chars'**
  String historyItemSubtitle(Object date, Object count);

  /// No description provided for @editorTitle.
  ///
  /// In fr, this message translates to:
  /// **'Éditeur'**
  String get editorTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres'**
  String get settingsTitle;

  /// No description provided for @presetCitation.
  ///
  /// In fr, this message translates to:
  /// **'Preset Citation'**
  String get presetCitation;

  /// No description provided for @chunkLimitTitle.
  ///
  /// In fr, this message translates to:
  /// **'Limite de découpage (paragraphes)'**
  String get chunkLimitTitle;

  /// No description provided for @limitNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucune (respecter les paragraphes)'**
  String get limitNone;

  /// No description provided for @limitWords.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de mots'**
  String get limitWords;

  /// No description provided for @limitChars.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de caractères'**
  String get limitChars;

  /// No description provided for @maxWordsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Max mots par paragraphe (ex: 90)'**
  String get maxWordsLabel;

  /// No description provided for @maxCharsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Max caractères par paragraphe (ex: 650)'**
  String get maxCharsLabel;

  /// No description provided for @chunkTip.
  ///
  /// In fr, this message translates to:
  /// **'Astuce: active le mode intelligent si les phrases sont très longues.'**
  String get chunkTip;

  /// No description provided for @smartRefactorTitle.
  ///
  /// In fr, this message translates to:
  /// **'Refactorisation intelligente'**
  String get smartRefactorTitle;

  /// No description provided for @modeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mode'**
  String get modeLabel;

  /// No description provided for @modeSoft.
  ///
  /// In fr, this message translates to:
  /// **'Doux (style naturel)'**
  String get modeSoft;

  /// No description provided for @modeStrict.
  ///
  /// In fr, this message translates to:
  /// **'Strict (plus structuré)'**
  String get modeStrict;

  /// No description provided for @modeAggressive.
  ///
  /// In fr, this message translates to:
  /// **'Agressif (coupe davantage)'**
  String get modeAggressive;

  /// No description provided for @smartSplitTitle.
  ///
  /// In fr, this message translates to:
  /// **'Découper les pensées longues intelligemment'**
  String get smartSplitTitle;

  /// No description provided for @smartSplitSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Phrase → ; : , → mots (fallback)'**
  String get smartSplitSubtitle;

  /// No description provided for @separatorTitle.
  ///
  /// In fr, this message translates to:
  /// **'Séparateur de paragraphe / strophe'**
  String get separatorTitle;

  /// No description provided for @separatorHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: \\n\\n ou ----'**
  String get separatorHint;

  /// No description provided for @ensurePunctTitle.
  ///
  /// In fr, this message translates to:
  /// **'Assurer ponctuation en fin de bloc'**
  String get ensurePunctTitle;

  /// No description provided for @strophesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Strophes & lignes (comme ton exemple)'**
  String get strophesTitle;

  /// No description provided for @outputFormatLabel.
  ///
  /// In fr, this message translates to:
  /// **'Format final'**
  String get outputFormatLabel;

  /// No description provided for @formatParagraph.
  ///
  /// In fr, this message translates to:
  /// **'Paragraphes classiques'**
  String get formatParagraph;

  /// No description provided for @formatStropheLines.
  ///
  /// In fr, this message translates to:
  /// **'Strophes (lignes)'**
  String get formatStropheLines;

  /// No description provided for @autoLineWidthTitle.
  ///
  /// In fr, this message translates to:
  /// **'Auto: largeur de ligne selon la fenêtre'**
  String get autoLineWidthTitle;

  /// No description provided for @autoLineWidthSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Mesure la zone résultat et ajuste chars/ligne'**
  String get autoLineWidthSubtitle;

  /// No description provided for @linesPerStropheLabel.
  ///
  /// In fr, this message translates to:
  /// **'Lignes / strophe (ex: 4)'**
  String get linesPerStropheLabel;

  /// No description provided for @charsPerLineLabel.
  ///
  /// In fr, this message translates to:
  /// **'Largeur ligne (chars)'**
  String get charsPerLineLabel;

  /// No description provided for @longWordsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mots très longs'**
  String get longWordsLabel;

  /// No description provided for @longWordHyphen.
  ///
  /// In fr, this message translates to:
  /// **'Mot long: découper avec \'-\''**
  String get longWordHyphen;

  /// No description provided for @longWordHard.
  ///
  /// In fr, this message translates to:
  /// **'Mot long: découper sans \'-\''**
  String get longWordHard;

  /// No description provided for @longWordOverflow.
  ///
  /// In fr, this message translates to:
  /// **'Mot long: ne pas couper (overflow)'**
  String get longWordOverflow;

  /// No description provided for @preserveHeadersTitle.
  ///
  /// In fr, this message translates to:
  /// **'Préserver les titres (*...*, §..., dates…)'**
  String get preserveHeadersTitle;

  /// No description provided for @smartStrophesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Strophes intelligentes (fin de phrase)'**
  String get smartStrophesTitle;

  /// No description provided for @smartStrophesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ferme une strophe sur une phrase complète quand c’est pertinent'**
  String get smartStrophesSubtitle;

  /// No description provided for @numberingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Numérotation automatique'**
  String get numberingTitle;

  /// No description provided for @numberingFormatLabel.
  ///
  /// In fr, this message translates to:
  /// **'Format (ex: 1)  |  1.  |  [1] )'**
  String get numberingFormatLabel;

  /// No description provided for @shortcutsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Raccourcis :'**
  String get shortcutsTitle;

  /// No description provided for @shortcutProcess.
  ///
  /// In fr, this message translates to:
  /// **'• Ctrl + Entrée : Refactoriser'**
  String get shortcutProcess;

  /// No description provided for @shortcutInsertSep.
  ///
  /// In fr, this message translates to:
  /// **'• Ctrl + Shift + Entrée : Insérer séparateur'**
  String get shortcutInsertSep;

  /// No description provided for @shortcutPreset.
  ///
  /// In fr, this message translates to:
  /// **'• Ctrl + Alt + B : Preset Citation'**
  String get shortcutPreset;

  /// No description provided for @reset.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get reset;

  /// No description provided for @processing.
  ///
  /// In fr, this message translates to:
  /// **'Traitement...'**
  String get processing;

  /// No description provided for @refactor.
  ///
  /// In fr, this message translates to:
  /// **'Refactoriser'**
  String get refactor;

  /// No description provided for @insertSeparator.
  ///
  /// In fr, this message translates to:
  /// **'Insérer séparateur'**
  String get insertSeparator;

  /// No description provided for @copyResult.
  ///
  /// In fr, this message translates to:
  /// **'Copier résultat'**
  String get copyResult;

  /// No description provided for @copied.
  ///
  /// In fr, this message translates to:
  /// **'Texte copié !'**
  String get copied;

  /// No description provided for @rawTextTitle.
  ///
  /// In fr, this message translates to:
  /// **'Texte brut'**
  String get rawTextTitle;

  /// No description provided for @generatedTextTitle.
  ///
  /// In fr, this message translates to:
  /// **'Texte généré'**
  String get generatedTextTitle;

  /// No description provided for @rawHint.
  ///
  /// In fr, this message translates to:
  /// **'Colle ton texte ici… (double Entrée = séparateur)'**
  String get rawHint;

  /// No description provided for @generatedHint.
  ///
  /// In fr, this message translates to:
  /// **'Le résultat apparaîtra ici… (modifiable)'**
  String get generatedHint;

  /// No description provided for @stats.
  ///
  /// In fr, this message translates to:
  /// **'Entrée: {inChars} chars  •  Sortie: {outChars} chars'**
  String stats(Object inChars, Object outChars);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
