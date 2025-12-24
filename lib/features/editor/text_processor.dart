import 'package:flutter/foundation.dart';
import 'package:characters/characters.dart';

import 'models.dart';

class TextProcessor {
  /// Use this in UI to avoid blocking (compute runs in isolate)
  static Future<String> processAsync(String input, RefactorSettings s) {
    return compute(_processEntry, {"input": input, "settings": s.toJson()});
  }

  /// Entry point for isolate (must be top-level or static, and payload must be sendable)
  static String _processEntry(Map<String, dynamic> payload) {
    final input = payload["input"] as String? ?? "";
    final settings = RefactorSettings.fromJson(
      (payload["settings"] as Map).cast<String, dynamic>(),
    );
    return process(input, settings);
  }

  static String process(String input, RefactorSettings s) {
    final cleaned = _normalize(input);
    if (cleaned.isEmpty) return "";

    final chunks = _splitIntoChunks(cleaned, s);

    final finalized = chunks.map((p) {
      var t = p.trim();
      if (t.isEmpty) return t;

      if (s.ensureEndPunctuation) {
        t = _ensurePunctuation(t);
      }

      // Optionnel: espaces avant ponctuation (FR) -> ici on ne force pas,
      // mais on supprime les doubles espaces créés par les opérations.
      t = t.replaceAll(RegExp(r"[ \t]{2,}"), " ").trim();
      return t;
    }).where((e) => e.trim().isNotEmpty).toList();

    if (finalized.isEmpty) return "";

    if (s.autoNumbering) {
      return _applyNumbering(finalized, s.numberingFormat, s.separator);
    }
    return finalized.join(s.separator);
  }

  // -------------------------
  // Normalisation robuste
  // -------------------------
  static String _normalize(String t) {
    var s = t;

    // Newlines normalization
    s = s.replaceAll("\r\n", "\n").replaceAll("\r", "\n");

    // Replace non-breaking spaces
    s = s.replaceAll("\u00A0", " ");

    // Trim trailing spaces per line (helps cleanup pasted text)
    s = s.split("\n").map((line) => line.trimRight()).join("\n");

    // Collapse excessive spaces/tabs
    s = s.replaceAll(RegExp(r"[ \t]+"), " ");

    // Normalize multiple blank lines (keep max 2)
    s = s.replaceAll(RegExp(r"\n{3,}"), "\n\n");

    return s.trim();
  }

  // -------------------------
  // Chunking
  // -------------------------
  static List<String> _splitIntoChunks(String t, RefactorSettings s) {
    // If no constraints, respect existing paragraphs (double newline)
    if (s.maxChars == null && s.maxWords == null) {
      return t
          .split(RegExp(r"\n{2,}"))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    final sentences = _splitSentencesSmart(t);
    final chunks = <String>[];
    var current = "";

    bool canAdd(String next) {
      if (current.isEmpty) return true;

      if (s.maxChars != null) {
        // +1 for a space between sentences
        return (current.length + 1 + next.length) <= s.maxChars!;
      }
      if (s.maxWords != null) {
        return (_wordCount(current) + _wordCount(next)) <= s.maxWords!;
      }
      return true;
    }

    for (final sent in sentences) {
      final piece = sent.trim();
      if (piece.isEmpty) continue;

      if (canAdd(piece)) {
        current = current.isEmpty ? piece : "$current $piece";
      } else {
        // Flush current
        if (current.trim().isNotEmpty) chunks.add(current.trim());
        current = piece;
      }
    }

    if (current.trim().isNotEmpty) chunks.add(current.trim());
    return chunks;
  }

  // -------------------------
  // Sentence splitting (puissant)
  // - évite abréviations
  // - gère guillemets/parenthèses après ponctuation
  // -------------------------
  static List<String> _splitSentencesSmart(String text) {
    final s = text.trim();
    if (s.isEmpty) return const [];

    // Common abbreviations list (FR/EN) - you can expand anytime
    final abbreviations = <String>{
      "m.", "mme.", "mlle.", "dr.", "pr.", "sr.", "st.", "ste.",
      "mr.", "mrs.", "ms.",
      "etc.", "e.g.", "i.e.", "vs.",
      "p.ex.", "ex.", "cf.",
      "n°", "no.", "vol.", "fig.", "al.",
      "jan.", "fév.", "fev.", "mar.", "avr.", "mai.", "juin.", "juil.", "août.", "aout.", "sept.", "sep.", "oct.", "nov.", "déc.", "dec.",
    };

    bool isSentenceEndPunct(String ch) => ch == "." || ch == "!" || ch == "?";

    bool isClosing(String ch) =>
        ch == "\"" ||
            ch == "”" ||
            ch == "’" ||
            ch == "'" ||
            ch == ")" ||
            ch == "]" ||
            ch == "}" ||
            ch == "»";

    bool isWhitespace(String ch) => RegExp(r"\s").hasMatch(ch);

    // Get last "token" before an index (for abbreviation check)
    String lastTokenBefore(List<String> chars, int endExclusive) {
      // endExclusive points to index AFTER current punctuation
      int i = endExclusive - 1;
      // Skip closing quotes/brackets right before endExclusive (rare here)
      while (i >= 0 && isClosing(chars[i])) i--;
      // Collect token backward until whitespace or line break
      final buff = <String>[];
      while (i >= 0 && !isWhitespace(chars[i])) {
        buff.add(chars[i]);
        i--;
      }
      return buff.reversed.join();
    }

    // Convert to grapheme list (emoji-safe, accents-safe)
    final chars = s.characters.toList();

    final sentences = <String>[];
    final buf = StringBuffer();

    for (int i = 0; i < chars.length; i++) {
      final ch = chars[i];
      buf.write(ch);

      // Hard paragraph boundaries: keep them as split points
      if (ch == "\n") {
        // If double newline, split paragraph.
        final next = (i + 1 < chars.length) ? chars[i + 1] : null;
        if (next == "\n") {
          // consume the second \n into buffer
          buf.write(next);
          i++;

          final candidate = buf.toString().trim();
          if (candidate.isNotEmpty) sentences.add(candidate);
          buf.clear();
        }
        continue;
      }

      // Candidate sentence end punctuation
      if (!isSentenceEndPunct(ch)) continue;

      // Look ahead: allow closing quotes/brackets immediately after punctuation
      int j = i + 1;
      while (j < chars.length && isClosing(chars[j])) {
        buf.write(chars[j]);
        j++;
        i++; // advance main loop too
      }

      // If next is end-of-text -> end sentence
      if (j >= chars.length) {
        final candidate = buf.toString().trim();
        if (candidate.isNotEmpty) sentences.add(candidate);
        buf.clear();
        break;
      }

      // If next is not whitespace/newline => likely not end of sentence (e.g., "3.14", "U.S.A.")
      final nextChar = chars[j];
      if (!isWhitespace(nextChar)) {
        continue;
      }

      // Abbreviation check (token before punctuation)
      final token = lastTokenBefore(chars, i + 1).toLowerCase();

      // Special case: single-letter initials like "A." "J.-P." shouldn’t always split
      final isInitial = RegExp(r"^[a-z]\.$").hasMatch(token);

      // Special case: decimal numbers "3.14" -> if previous char is digit and next non-space digit
      final prev = (i - 1 >= 0) ? chars[i - 1] : "";
      final afterSpaceIndex = _skipSpaces(chars, j);
      final afterSpace = afterSpaceIndex < chars.length ? chars[afterSpaceIndex] : "";
      final isDecimal = RegExp(r"\d").hasMatch(prev) && RegExp(r"\d").hasMatch(afterSpace);

      final isAbbrev = abbreviations.contains(token) || isInitial || token.endsWith(".."); // small heuristic

      if (isDecimal || isAbbrev) {
        continue;
      }

      // End sentence
      final candidate = buf.toString().trim();
      if (candidate.isNotEmpty) sentences.add(candidate);
      buf.clear();

      // Skip the whitespace after punctuation to avoid starting next sentence with spaces
      // (But keep newlines if any)
      while (j < chars.length && chars[j] == " ") j++;
      i = j - 1; // because loop will i++
    }

    final remaining = buf.toString().trim();
    if (remaining.isNotEmpty) sentences.add(remaining);

    // Post-process: split huge blocks by double newline if any survived
    final out = <String>[];
    for (final item in sentences) {
      final parts = item
          .split(RegExp(r"\n{2,}"))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty);
      out.addAll(parts);
    }
    return out;
  }

  static int _skipSpaces(List<String> chars, int i) {
    var j = i;
    while (j < chars.length && chars[j] == " ") j++;
    return j;
  }

  static int _wordCount(String t) =>
      t.trim().isEmpty ? 0 : t.trim().split(RegExp(r"\s+")).length;

  // -------------------------
  // Ensure punctuation (emoji-safe)
  // - ignore trailing quotes/brackets
  // -------------------------
  static String _ensurePunctuation(String t) {
    final trimmed = t.trimRight();
    if (trimmed.isEmpty) return t;

    bool isPunct(String ch) => ch == "." || ch == "!" || ch == "?";
    bool isClosing(String ch) =>
        ch == "\"" ||
            ch == "”" ||
            ch == "’" ||
            ch == "'" ||
            ch == ")" ||
            ch == "]" ||
            ch == "}" ||
            ch == "»";

    final graphemes = trimmed.characters.toList();

    // Walk backwards skipping closings
    int i = graphemes.length - 1;
    while (i >= 0 && isClosing(graphemes[i])) {
      i--;
    }
    if (i < 0) return "$t."; // only closings? add punctuation anyway

    final lastMeaningful = graphemes[i];
    if (isPunct(lastMeaningful)) return t;

    // Insert punctuation before trailing closings if present
    final tail = graphemes.sublist(i + 1).join(); // closings
    final head = graphemes.sublist(0, i + 1).join();
    return "$head.$tail";
  }

  static String _applyNumbering(List<String> paras, String fmt, String sep) {
    return List.generate(paras.length, (i) {
      final n = i + 1;
      final prefix = fmt.replaceFirst("1", n.toString());
      return "$prefix${paras[i]}";
    }).join(sep);
  }
}
