class RefactorSettings {
  final int? maxWords;
  final int? maxChars;

  /// Separator between paragraphs
  final String separator;

  /// Ensure punctuation (.,!,?) at the end of each paragraph
  final bool ensureEndPunctuation;

  /// Auto numbering
  final bool autoNumbering;

  /// Example: "1) ", "1. ", "[1] "
  final String numberingFormat;

  const RefactorSettings({
    this.maxWords,
    this.maxChars,
    this.separator = "\n\n",
    this.ensureEndPunctuation = true,
    this.autoNumbering = false,
    this.numberingFormat = "1) ",
  });

  RefactorSettings copyWith({
    int? maxWords,
    int? maxChars,
    String? separator,
    bool? ensureEndPunctuation,
    bool? autoNumbering,
    String? numberingFormat,
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
    );
  }

  Map<String, dynamic> toJson() => {
    "maxWords": maxWords,
    "maxChars": maxChars,
    "separator": separator,
    "ensureEndPunctuation": ensureEndPunctuation,
    "autoNumbering": autoNumbering,
    "numberingFormat": numberingFormat,
  };

  static RefactorSettings fromJson(Map<String, dynamic> json) {
    return RefactorSettings(
      maxWords: json["maxWords"] as int?,
      maxChars: json["maxChars"] as int?,
      separator: (json["separator"] as String?) ?? "\n\n",
      ensureEndPunctuation: (json["ensureEndPunctuation"] as bool?) ?? true,
      autoNumbering: (json["autoNumbering"] as bool?) ?? false,
      numberingFormat: (json["numberingFormat"] as String?) ?? "1) ",
    );
  }
}

enum LimitMode { none, words, chars }
