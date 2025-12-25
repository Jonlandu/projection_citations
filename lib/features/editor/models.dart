enum LimitMode { none, words, chars }

enum RefactorMode { soft, strict, aggressive }

enum LongWordPolicy {
  breakWithHyphen,
  hardBreak,
  overflow,
}

enum OutputLayoutMode {
  paragraph,
  stropheLines,
}

class RefactorSettings {
  // LIMITES DE DÉCOUPAGE (chunks)
  final int? maxWords;
  final int? maxChars;

  // FORMAT
  final String separator;
  final bool ensureEndPunctuation;

  // NUMÉROTATION
  final bool autoNumbering;
  final String numberingFormat;

  // INTELLIGENCE
  final RefactorMode mode;
  final bool smartSplitLongSentences;
  final bool keepSeparatorPunctuation;

  // STROPHES & LIGNES
  final OutputLayoutMode layoutMode;
  final int linesPerStrophe;
  final int charsPerLine;
  final LongWordPolicy longWordPolicy;
  final bool preserveHeaderLines;

  // ✅ NEW: strophes intelligentes
  final bool smartStropheBreaks;

  const RefactorSettings({
    this.maxWords,
    this.maxChars,
    this.separator = "\n\n",
    this.ensureEndPunctuation = true,
    this.autoNumbering = false,
    this.numberingFormat = "1) ",
    this.mode = RefactorMode.soft,
    this.smartSplitLongSentences = true,
    this.keepSeparatorPunctuation = true,
    this.layoutMode = OutputLayoutMode.paragraph,
    this.linesPerStrophe = 4,
    this.charsPerLine = 42,
    this.longWordPolicy = LongWordPolicy.breakWithHyphen,
    this.preserveHeaderLines = true,
    this.smartStropheBreaks = true,
  });

  RefactorSettings copyWith({
    int? maxWords,
    int? maxChars,
    String? separator,
    bool? ensureEndPunctuation,
    bool? autoNumbering,
    String? numberingFormat,
    RefactorMode? mode,
    bool? smartSplitLongSentences,
    bool? keepSeparatorPunctuation,
    OutputLayoutMode? layoutMode,
    int? linesPerStrophe,
    int? charsPerLine,
    LongWordPolicy? longWordPolicy,
    bool? preserveHeaderLines,
    bool? smartStropheBreaks,
    bool clearMaxWords = false,
    bool clearMaxChars = false,
  }) {
    return RefactorSettings(
      maxWords: clearMaxWords ? null : (maxWords ?? this.maxWords),
      maxChars: clearMaxChars ? null : (maxChars ?? this.maxChars),
      separator: separator ?? this.separator,
      ensureEndPunctuation: ensureEndPunctuation ?? this.ensureEndPunctuation,
      autoNumbering: autoNumbering ?? this.autoNumbering,
      numberingFormat: numberingFormat ?? this.numberingFormat,
      mode: mode ?? this.mode,
      smartSplitLongSentences: smartSplitLongSentences ?? this.smartSplitLongSentences,
      keepSeparatorPunctuation: keepSeparatorPunctuation ?? this.keepSeparatorPunctuation,
      layoutMode: layoutMode ?? this.layoutMode,
      linesPerStrophe: linesPerStrophe ?? this.linesPerStrophe,
      charsPerLine: charsPerLine ?? this.charsPerLine,
      longWordPolicy: longWordPolicy ?? this.longWordPolicy,
      preserveHeaderLines: preserveHeaderLines ?? this.preserveHeaderLines,
      smartStropheBreaks: smartStropheBreaks ?? this.smartStropheBreaks,
    );
  }

  Map<String, dynamic> toJson() => {
    "maxWords": maxWords,
    "maxChars": maxChars,
    "separator": separator,
    "ensureEndPunctuation": ensureEndPunctuation,
    "autoNumbering": autoNumbering,
    "numberingFormat": numberingFormat,
    "mode": mode.name,
    "smartSplitLongSentences": smartSplitLongSentences,
    "keepSeparatorPunctuation": keepSeparatorPunctuation,
    "layoutMode": layoutMode.name,
    "linesPerStrophe": linesPerStrophe,
    "charsPerLine": charsPerLine,
    "longWordPolicy": longWordPolicy.name,
    "preserveHeaderLines": preserveHeaderLines,
    "smartStropheBreaks": smartStropheBreaks,
  };

  static RefactorSettings fromJson(Map<String, dynamic> json) {
    RefactorMode parseMode(String? v) => RefactorMode.values.firstWhere(
          (e) => e.name == v,
      orElse: () => RefactorMode.soft,
    );

    OutputLayoutMode parseLayout(String? v) => OutputLayoutMode.values.firstWhere(
          (e) => e.name == v,
      orElse: () => OutputLayoutMode.paragraph,
    );

    LongWordPolicy parseLongWord(String? v) => LongWordPolicy.values.firstWhere(
          (e) => e.name == v,
      orElse: () => LongWordPolicy.breakWithHyphen,
    );

    return RefactorSettings(
      maxWords: json["maxWords"] as int?,
      maxChars: json["maxChars"] as int?,
      separator: (json["separator"] as String?) ?? "\n\n",
      ensureEndPunctuation: (json["ensureEndPunctuation"] as bool?) ?? true,
      autoNumbering: (json["autoNumbering"] as bool?) ?? false,
      numberingFormat: (json["numberingFormat"] as String?) ?? "1) ",
      mode: parseMode(json["mode"] as String?),
      smartSplitLongSentences: (json["smartSplitLongSentences"] as bool?) ?? true,
      keepSeparatorPunctuation: (json["keepSeparatorPunctuation"] as bool?) ?? true,
      layoutMode: parseLayout(json["layoutMode"] as String?),
      linesPerStrophe: (json["linesPerStrophe"] as int?) ?? 4,
      charsPerLine: (json["charsPerLine"] as int?) ?? 42,
      longWordPolicy: parseLongWord(json["longWordPolicy"] as String?),
      preserveHeaderLines: (json["preserveHeaderLines"] as bool?) ?? true,
      smartStropheBreaks: (json["smartStropheBreaks"] as bool?) ?? true,
    );
  }
}
