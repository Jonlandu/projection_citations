// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'ProjectionCitations';

  @override
  String get welcomeTitle => 'Bem-vindo';

  @override
  String get welcomeSubtitle =>
      'Aplicação offline para refatoração e formatação inteligente de textos.';

  @override
  String get welcomeBullets =>
      '• Cole um texto bruto\n• Configure o recorte (palavras / caracteres)\n• Gere um texto limpo e estruturado\n• Copie sem obrigação de salvar\n';

  @override
  String get start => 'Começar';

  @override
  String get language => 'Idioma';

  @override
  String get systemLanguage => 'Idioma do sistema';

  @override
  String get french => 'Francês';

  @override
  String get english => 'Inglês';

  @override
  String get portuguese => 'Português';

  @override
  String get helpTitle => 'Ajuda';

  @override
  String get helpHeader => 'Ajuda & Guia';

  @override
  String get helpBody =>
      '1) Cole o texto bruto na área \'Texto bruto\'.\n2) Configure os parâmetros (palavras, caracteres, separador, pontuação, numeração).\n3) Clique em \'Refatorar\' (ou Ctrl + Enter).\n4) Você pode editar o texto gerado.\n5) Clique em \'Copiar resultado\' para copiar.\n\nDicas:\n- Para manter os parágrafos existentes: selecione \'Nenhum\' no limite.\n- Para criar parágrafos equilibrados: use \'Número de palavras\' (ex: 60–120).\n- O separador aceita \\n para quebra de linha (ex: \\n\\n).';

  @override
  String get helpNumberingExamplesTitle => 'Exemplos de formato de numeração';

  @override
  String get helpNumberingExamples => '- 1) \n- 1. \n- [1] \n';

  @override
  String get historyTitle => 'Histórico';

  @override
  String get historyEmpty => 'Nenhum histórico por enquanto.';

  @override
  String get deleteAll => 'Apagar tudo';

  @override
  String get historyCleared => 'Histórico apagado';

  @override
  String get entryDeleted => 'Entrada apagada';

  @override
  String get undo => 'DESFAZER';

  @override
  String get delete => 'Apagar';

  @override
  String historyItemSubtitle(Object date, Object count) {
    return 'Em $date • $count caracteres';
  }

  @override
  String get editorTitle => 'Editor';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get presetCitation => 'Preset de Citação';

  @override
  String get chunkLimitTitle => 'Limite de recorte (parágrafos)';

  @override
  String get limitNone => 'Nenhum (manter parágrafos existentes)';

  @override
  String get limitWords => 'Número de palavras';

  @override
  String get limitChars => 'Número de caracteres';

  @override
  String get maxWordsLabel => 'Máx. palavras por parágrafo (ex: 90)';

  @override
  String get maxCharsLabel => 'Máx. caracteres por parágrafo (ex: 650)';

  @override
  String get chunkTip =>
      'Dica: ative o modo inteligente se as frases forem muito longas.';

  @override
  String get smartRefactorTitle => 'Refatoração inteligente';

  @override
  String get modeLabel => 'Modo';

  @override
  String get modeSoft => 'Suave (estilo natural)';

  @override
  String get modeStrict => 'Rigoroso (mais estruturado)';

  @override
  String get modeAggressive => 'Agressivo (recorta mais)';

  @override
  String get smartSplitTitle =>
      'Recortar pensamentos longos de forma inteligente';

  @override
  String get smartSplitSubtitle => 'Frase → ; : , → palavras (fallback)';

  @override
  String get separatorTitle => 'Separador de parágrafo / estrofe';

  @override
  String get separatorHint => 'Ex: \\n\\n ou ----';

  @override
  String get ensurePunctTitle => 'Garantir pontuação no fim do bloco';

  @override
  String get strophesTitle => 'Estrofes & linhas (como no seu exemplo)';

  @override
  String get outputFormatLabel => 'Formato final';

  @override
  String get formatParagraph => 'Parágrafos clássicos';

  @override
  String get formatStropheLines => 'Estrofes (linhas)';

  @override
  String get autoLineWidthTitle => 'Auto: largura da linha conforme a janela';

  @override
  String get autoLineWidthSubtitle =>
      'Mede a área do resultado e ajusta chars/linha';

  @override
  String get linesPerStropheLabel => 'Linhas por estrofe (ex: 4)';

  @override
  String get charsPerLineLabel => 'Largura da linha (chars)';

  @override
  String get longWordsLabel => 'Palavras muito longas';

  @override
  String get longWordHyphen => 'Palavra longa: dividir com \'-\'';

  @override
  String get longWordHard => 'Palavra longa: dividir sem \'-\'';

  @override
  String get longWordOverflow => 'Palavra longa: não dividir (overflow)';

  @override
  String get preserveHeadersTitle => 'Preservar títulos (*...*, §..., datas…)';

  @override
  String get smartStrophesTitle => 'Estrofes inteligentes (fim da frase)';

  @override
  String get smartStrophesSubtitle =>
      'Prefere fechar a estrofe numa frase completa quando possível';

  @override
  String get numberingTitle => 'Numeração automática';

  @override
  String get numberingFormatLabel => 'Formato (ex: 1)  |  1.  |  [1] )';

  @override
  String get shortcutsTitle => 'Atalhos:';

  @override
  String get shortcutProcess => '• Ctrl + Enter: Refatorar';

  @override
  String get shortcutInsertSep => '• Ctrl + Shift + Enter: Inserir separador';

  @override
  String get shortcutPreset => '• Ctrl + Alt + B: Preset de Citação';

  @override
  String get reset => 'Reiniciar';

  @override
  String get processing => 'Processando...';

  @override
  String get refactor => 'Refatorar';

  @override
  String get insertSeparator => 'Inserir separador';

  @override
  String get copyResult => 'Copiar resultado';

  @override
  String get copied => 'Texto copiado!';

  @override
  String get rawTextTitle => 'Texto bruto';

  @override
  String get generatedTextTitle => 'Texto gerado';

  @override
  String get rawHint => 'Cole seu texto aqui… (duplo Enter = separador)';

  @override
  String get generatedHint => 'O resultado aparecerá aqui… (editável)';

  @override
  String stats(Object inChars, Object outChars) {
    return 'Entrada: $inChars chars  •  Saída: $outChars chars';
  }
}
