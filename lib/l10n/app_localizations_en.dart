// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ProjectionCitations';

  @override
  String get welcomeTitle => 'Welcome';

  @override
  String get welcomeSubtitle =>
      'Offline application for intelligent text refactoring and formatting.';

  @override
  String get welcomeBullets =>
      '• Paste a raw text\n• Configure the splitting (words / characters)\n• Generate a clean and structured text\n• Copy without mandatory saving\n';

  @override
  String get start => 'Get started';

  @override
  String get language => 'Language';

  @override
  String get systemLanguage => 'System language';

  @override
  String get french => 'French';

  @override
  String get english => 'English';

  @override
  String get portuguese => 'Portuguese';

  @override
  String get helpTitle => 'Help';

  @override
  String get helpHeader => 'Help & Guide';

  @override
  String get helpBody =>
      '1) Paste your raw text into the \'Raw text\' area.\n2) Configure the settings (words, characters, separator, punctuation, numbering).\n3) Click on \'Refactor\' (or Ctrl + Enter).\n4) You can edit the generated text.\n5) Click on \'Copy result\' to copy.\n\nTips:\n- To keep existing paragraphs: set the limit to \'None\'.\n- To create balanced paragraphs: use \'Word count\' (e.g. 60–120).\n- The separator accepts \\n for line breaks (e.g. \\n\\n).';

  @override
  String get helpNumberingExamplesTitle => 'Numbering format examples';

  @override
  String get helpNumberingExamples => '- 1) \n- 1. \n- [1] \n';

  @override
  String get historyTitle => 'History';

  @override
  String get historyEmpty => 'No history yet.';

  @override
  String get deleteAll => 'Delete all';

  @override
  String get historyCleared => 'History cleared';

  @override
  String get entryDeleted => 'Entry deleted';

  @override
  String get undo => 'UNDO';

  @override
  String get delete => 'Delete';

  @override
  String historyItemSubtitle(Object date, Object count) {
    return 'On $date • $count chars';
  }

  @override
  String get editorTitle => 'Editor';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get presetCitation => 'Citation Preset';

  @override
  String get chunkLimitTitle => 'Split limit (paragraphs)';

  @override
  String get limitNone => 'None (keep existing paragraphs)';

  @override
  String get limitWords => 'Word count';

  @override
  String get limitChars => 'Character count';

  @override
  String get maxWordsLabel => 'Max words per paragraph (e.g. 90)';

  @override
  String get maxCharsLabel => 'Max characters per paragraph (e.g. 650)';

  @override
  String get chunkTip => 'Tip: enable smart mode if sentences are very long.';

  @override
  String get smartRefactorTitle => 'Smart refactoring';

  @override
  String get modeLabel => 'Mode';

  @override
  String get modeSoft => 'Soft (natural style)';

  @override
  String get modeStrict => 'Strict (more structured)';

  @override
  String get modeAggressive => 'Aggressive (splits more)';

  @override
  String get smartSplitTitle => 'Smartly split long thoughts';

  @override
  String get smartSplitSubtitle => 'Sentence → ; : , → words (fallback)';

  @override
  String get separatorTitle => 'Paragraph / strophe separator';

  @override
  String get separatorHint => 'e.g. \\n\\n or ----';

  @override
  String get ensurePunctTitle => 'Ensure punctuation at the end of each block';

  @override
  String get strophesTitle => 'Strophes & lines (like your example)';

  @override
  String get outputFormatLabel => 'Final format';

  @override
  String get formatParagraph => 'Classic paragraphs';

  @override
  String get formatStropheLines => 'Strophes (lines)';

  @override
  String get autoLineWidthTitle => 'Auto: line width based on window';

  @override
  String get autoLineWidthSubtitle =>
      'Measures the result area and adjusts chars/line';

  @override
  String get linesPerStropheLabel => 'Lines per strophe (e.g. 4)';

  @override
  String get charsPerLineLabel => 'Line width (chars)';

  @override
  String get longWordsLabel => 'Very long words';

  @override
  String get longWordHyphen => 'Long word: split with \'-\'';

  @override
  String get longWordHard => 'Long word: split without \'-\'';

  @override
  String get longWordOverflow => 'Long word: do not split (overflow)';

  @override
  String get preserveHeadersTitle => 'Preserve headers (*...*, §..., dates…)';

  @override
  String get smartStrophesTitle => 'Smart strophes (end of sentence)';

  @override
  String get smartStrophesSubtitle =>
      'Prefer ending a strophe on a complete sentence when possible';

  @override
  String get numberingTitle => 'Automatic numbering';

  @override
  String get numberingFormatLabel => 'Format (e.g. 1)  |  1.  |  [1] )';

  @override
  String get shortcutsTitle => 'Shortcuts:';

  @override
  String get shortcutProcess => '• Ctrl + Enter: Refactor';

  @override
  String get shortcutInsertSep => '• Ctrl + Shift + Enter: Insert separator';

  @override
  String get shortcutPreset => '• Ctrl + Alt + B: Citation Preset';

  @override
  String get reset => 'Reset';

  @override
  String get processing => 'Processing...';

  @override
  String get refactor => 'Refactor';

  @override
  String get insertSeparator => 'Insert separator';

  @override
  String get copyResult => 'Copy result';

  @override
  String get copied => 'Text copied!';

  @override
  String get rawTextTitle => 'Raw text';

  @override
  String get generatedTextTitle => 'Generated text';

  @override
  String get rawHint => 'Paste your text here… (double Enter = separator)';

  @override
  String get generatedHint => 'Result will appear here… (editable)';

  @override
  String stats(Object inChars, Object outChars) {
    return 'Input: $inChars chars  •  Output: $outChars chars';
  }
}
