import 'package:flutter/foundation.dart';
import 'package:characters/characters.dart';

import 'models.dart';

class TextProcessor {
  static Future<String> processAsync(String input, RefactorSettings s) {
    return compute(_processEntry, {"input": input, "settings": s.toJson()});
  }

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

    // 1) découpage intelligent en chunks (paragraph-ready)
    final chunks = _splitIntoChunksSmart(cleaned, s);

    // 2) post-traitement (ponctuation + espaces)
    final finalized = chunks
        .map((p) {
      var t = p.trim();
      if (t.isEmpty) return "";
      if (s.ensureEndPunctuation) t = _ensurePunctuation(t);
      t = t.replaceAll(RegExp(r"[ \t]{2,}"), " ").trim();
      return t;
    })
        .where((e) => e.isNotEmpty)
        .toList();

    if (finalized.isEmpty) return "";

    // 3) numérotation si demandée (avant layout strophes)
    final numbered = s.autoNumbering
        ? _applyNumbering(finalized, s.numberingFormat)
        : finalized;

    // 4) mise en forme finale: paragraphe normal OU strophes de lignes
    if (s.layoutMode == OutputLayoutMode.stropheLines) {
      return _toStrophes(numbered, s);
    }
    return numbered.join(s.separator);
  }

  // -------------------------
  // Normalize
  // -------------------------
  static String _normalize(String t) {
    var s = t;
    s = s.replaceAll("\r\n", "\n").replaceAll("\r", "\n");
    s = s.replaceAll("\u00A0", " ");
    s = s.split("\n").map((line) => line.trimRight()).join("\n");
    s = s.replaceAll(RegExp(r"[ \t]+"), " ");
    s = s.replaceAll(RegExp(r"\n{3,}"), "\n\n");
    return s.trim();
  }

  // -------------------------
  // Smart chunking pipeline
  // -------------------------
  static List<String> _splitIntoChunksSmart(String t, RefactorSettings s) {
    // No constraints => keep original paragraphs
    if (s.maxChars == null && s.maxWords == null) {
      return t
          .split(RegExp(r"\n{2,}"))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    final sentences = _splitSentencesSmart(t);

    // Expand long sentences (coherent split)
    final expanded = <String>[];
    for (final sent in sentences) {
      if (_fits(sent, s)) {
        expanded.add(sent);
      } else {
        expanded.addAll(_splitLongThought(sent, s));
      }
    }

    // Pack into paragraphs
    final chunks = <String>[];
    var current = "";

    for (final part in expanded) {
      final piece = part.trim();
      if (piece.isEmpty) continue;

      if (current.isEmpty) {
        current = piece;
        continue;
      }

      final candidate = "$current $piece";
      if (_fits(candidate, s)) {
        current = candidate;
      } else {
        chunks.add(current.trim());
        current = piece;
      }
    }

    if (current.trim().isNotEmpty) chunks.add(current.trim());
    return chunks;
  }

  static bool _fits(String text, RefactorSettings s) {
    if (s.maxChars != null) return text.length <= s.maxChars!;
    if (s.maxWords != null) return _wordCount(text) <= s.maxWords!;
    return true;
  }

  // -------------------------
  // Long thought splitting (coherent)
  // -------------------------
  static List<String> _splitLongThought(String sentence, RefactorSettings s) {
    final txt = sentence.trim();
    if (txt.isEmpty) return const [];

    if (!s.smartSplitLongSentences) {
      return _splitByWords(txt, s);
    }

    final separators = switch (s.mode) {
      RefactorMode.soft => <String>{";", ":"},
      RefactorMode.strict => <String>{";", ":", ","},
      RefactorMode.aggressive => <String>{";", ":", ",", "—", "-"},
    };

    // 1) split by separators
    final bySep = _splitBySeparators(txt, separators);

    // 2) ensure each piece fits; fallback to word split
    final out = <String>[];
    for (final piece in bySep) {
      if (_fits(piece, s)) {
        out.add(piece);
      } else {
        out.addAll(_splitByWords(piece, s));
      }
    }

    // Soft mode: merge micro pieces to avoid “haché”
    if (s.mode == RefactorMode.soft && out.length > 1) {
      final merged = <String>[];
      var curr = "";
      for (final p in out) {
        if (curr.isEmpty) {
          curr = p;
          continue;
        }
        if (_wordCount(curr) < 6) {
          curr = "$curr $p".trim();
        } else {
          merged.add(curr);
          curr = p;
        }
      }
      if (curr.isNotEmpty) merged.add(curr);
      return merged;
    }

    return out;
  }

  static List<String> _splitBySeparators(String text, Set<String> seps) {
    final chars = text.characters.toList();
    final parts = <String>[];
    final buf = StringBuffer();

    for (final ch in chars) {
      buf.write(ch);
      if (seps.contains(ch)) {
        final seg = buf.toString().trim();
        if (seg.isNotEmpty) parts.add(seg);
        buf.clear();
      }
    }

    final rem = buf.toString().trim();
    if (rem.isNotEmpty) parts.add(rem);

    return parts;
  }

  static List<String> _splitByWords(String text, RefactorSettings s) {
    final words = text.trim().split(RegExp(r"\s+"));
    if (words.isEmpty) return const [];

    // If limiting by chars, approximate word capacity
    final maxWords = s.maxWords ??
        (s.maxChars != null ? _approxWordsForChars(s.maxChars!) : 80);

    final out = <String>[];
    var current = <String>[];

    for (final w in words) {
      if (current.isEmpty) {
        current.add(w);
        continue;
      }

      final candidate = [...current, w].join(" ");
      final ok = s.maxChars != null ? candidate.length <= s.maxChars! : (current.length + 1) <= maxWords;

      if (ok) {
        current.add(w);
      } else {
        out.add(current.join(" "));
        current = [w];
      }
    }

    if (current.isNotEmpty) out.add(current.join(" "));
    return out;
  }

  static int _approxWordsForChars(int chars) {
    final v = (chars / 6).floor();
    return v.clamp(10, 400);
  }

  // -------------------------
  // Sentence splitting (robust)
  // -------------------------
  static List<String> _splitSentencesSmart(String text) {
    final s = text.trim();
    if (s.isEmpty) return const [];

    final abbreviations = <String>{
      "m.", "mme.", "mlle.", "dr.", "pr.", "sr.", "st.", "ste.",
      "mr.", "mrs.", "ms.",
      "etc.", "e.g.", "i.e.", "vs.",
      "p.ex.", "ex.", "cf.",
      "no.", "vol.", "fig.", "al.",
      "jan.", "fév.", "fev.", "mar.", "avr.", "mai.", "juin.", "juil.", "août.", "aout.", "sept.", "sep.", "oct.", "nov.", "déc.", "dec.",
    };

    bool isEnd(String ch) => ch == "." || ch == "!" || ch == "?";
    bool isClosing(String ch) =>
        ch == "\"" || ch == "”" || ch == "’" || ch == "'" || ch == ")" || ch == "]" || ch == "}" || ch == "»";
    bool isWs(String ch) => RegExp(r"\s").hasMatch(ch);

    String lastTokenBefore(List<String> chars, int endExclusive) {
      int i = endExclusive - 1;
      while (i >= 0 && isClosing(chars[i])) i--;
      final buff = <String>[];
      while (i >= 0 && !isWs(chars[i])) {
        buff.add(chars[i]);
        i--;
      }
      return buff.reversed.join();
    }

    final chars = s.characters.toList();
    final sentences = <String>[];
    final buf = StringBuffer();

    for (int i = 0; i < chars.length; i++) {
      final ch = chars[i];
      buf.write(ch);

      if (ch == "\n") {
        // preserve paragraph boundaries
        final next = (i + 1 < chars.length) ? chars[i + 1] : null;
        if (next == "\n") {
          buf.write(next);
          i++;
          final candidate = buf.toString().trim();
          if (candidate.isNotEmpty) sentences.add(candidate);
          buf.clear();
        }
        continue;
      }

      if (!isEnd(ch)) continue;

      // include trailing closings
      int j = i + 1;
      while (j < chars.length && isClosing(chars[j])) {
        buf.write(chars[j]);
        j++;
        i++;
      }

      if (j >= chars.length) {
        final candidate = buf.toString().trim();
        if (candidate.isNotEmpty) sentences.add(candidate);
        buf.clear();
        break;
      }

      final nextChar = chars[j];
      if (!isWs(nextChar)) continue;

      final token = lastTokenBefore(chars, i + 1).toLowerCase();
      final isInitial = RegExp(r"^[a-z]\.$").hasMatch(token);

      final prev = (i - 1 >= 0) ? chars[i - 1] : "";
      final afterSpaceIndex = _skipSpaces(chars, j);
      final afterSpace = afterSpaceIndex < chars.length ? chars[afterSpaceIndex] : "";
      final isDecimal = RegExp(r"\d").hasMatch(prev) && RegExp(r"\d").hasMatch(afterSpace);

      final isAbbrev = abbreviations.contains(token) || isInitial;
      if (isDecimal || isAbbrev) continue;

      final candidate = buf.toString().trim();
      if (candidate.isNotEmpty) sentences.add(candidate);
      buf.clear();

      while (j < chars.length && chars[j] == " ") j++;
      i = j - 1;
    }

    final remaining = buf.toString().trim();
    if (remaining.isNotEmpty) sentences.add(remaining);

    // safety: split by double newline
    final out = <String>[];
    for (final item in sentences) {
      out.addAll(
        item.split(RegExp(r"\n{2,}")).map((e) => e.trim()).where((e) => e.isNotEmpty),
      );
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
  // Ensure punctuation (emoji-safe + closings)
  // -------------------------
  static String _ensurePunctuation(String t) {
    final trimmed = t.trimRight();
    if (trimmed.isEmpty) return t;

    bool isPunct(String ch) => ch == "." || ch == "!" || ch == "?";
    bool isClosing(String ch) =>
        ch == "\"" || ch == "”" || ch == "’" || ch == "'" || ch == ")" || ch == "]" || ch == "}" || ch == "»";

    final graphemes = trimmed.characters.toList();

    int i = graphemes.length - 1;
    while (i >= 0 && isClosing(graphemes[i])) i--;
    if (i < 0) return "$t.";

    final lastMeaningful = graphemes[i];
    if (isPunct(lastMeaningful)) return t;

    final tail = graphemes.sublist(i + 1).join();
    final head = graphemes.sublist(0, i + 1).join();
    return "$head.$tail";
  }

  static List<String> _applyNumbering(List<String> paras, String fmt) {
    return List.generate(paras.length, (i) {
      final n = i + 1;
      final prefix = fmt.replaceFirst("1", n.toString());
      return "$prefix${paras[i]}";
    });
  }

  // ==========================================================
  // STROPHES MODE: wrap -> group lines -> output
  // ==========================================================

  static String _toStrophes(List<String> blocks, RefactorSettings s) {
    final allOutputLines = <String>[];
    final sep = s.separator; // usually \n\n

    for (final block in blocks) {
      final lines = _wrapBlockToLines(block, s);
      if (lines.isEmpty) continue;

      // group lines into strophes
      final strophes = <List<String>>[];
      for (int i = 0; i < lines.length; i += s.linesPerStrophe) {
        strophes.add(lines.sublist(i, (i + s.linesPerStrophe).clamp(0, lines.length)));
      }

      // join each strophe with single newline, and separate strophes with separator
      final stropheText = strophes.map((st) => st.join("\n")).join(sep);

      allOutputLines.add(stropheText);
    }

    return allOutputLines.join(sep);
  }

  static List<String> _wrapBlockToLines(String block, RefactorSettings s) {
    final rawLines = block.split("\n").map((e) => e.trim()).toList();

    final out = <String>[];
    for (final line in rawLines) {
      if (line.isEmpty) continue;

      // Preserve header-like lines (as in your example)
      if (s.preserveHeaderLines && _isHeaderLine(line)) {
        out.add(line);
        continue;
      }

      out.addAll(
        _wrapTextToLines(
          line,
          width: s.charsPerLine.clamp(10, 200),
          longWordPolicy: s.longWordPolicy,
        ),
      );
    }
    return out;
  }

  static bool _isHeaderLine(String line) {
    final l = line.trim();
    if (l.startsWith("*") && l.endsWith("*") && l.length >= 3) return true; // *Title*
    if (l.startsWith("§")) return true;
    if (RegExp(r"^\d{1,2}\.\d{1,2}\.\d{2,4}").hasMatch(l)) return true; // date 25.07.1965
    if (RegExp(r"^-+\s*fin\s+de\s+citation\s*-+$", caseSensitive: false).hasMatch(l)) return true;
    return false;
  }

  static List<String> _wrapTextToLines(
      String text, {
        required int width,
        required LongWordPolicy longWordPolicy,
      }) {
    final words = text.split(RegExp(r"\s+")).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return const [];

    final lines = <String>[];
    var current = "";

    void pushCurrent() {
      if (current.trim().isNotEmpty) lines.add(current.trim());
      current = "";
    }

    for (final w in words) {
      if (current.isEmpty) {
        // word itself may be too long
        if (w.length <= width || longWordPolicy == LongWordPolicy.overflow) {
          current = w;
        } else {
          // break long word into chunks
          final parts = _breakLongWord(w, width, longWordPolicy);
          // first part goes into current
          current = parts.first;
          // remaining parts become full lines
          for (int i = 1; i < parts.length; i++) {
            pushCurrent();
            current = parts[i];
          }
        }
        continue;
      }

      final candidate = "$current $w";
      if (candidate.length <= width || longWordPolicy == LongWordPolicy.overflow) {
        current = candidate;
      } else {
        // push current line
        pushCurrent();

        // start new line with w
        if (w.length <= width || longWordPolicy == LongWordPolicy.overflow) {
          current = w;
        } else {
          final parts = _breakLongWord(w, width, longWordPolicy);
          current = parts.first;
          for (int i = 1; i < parts.length; i++) {
            pushCurrent();
            current = parts[i];
          }
        }
      }
    }

    pushCurrent();
    return lines;
  }

  static List<String> _breakLongWord(String w, int width, LongWordPolicy policy) {
    if (policy == LongWordPolicy.overflow) return [w];
    if (width <= 4) return [w]; // too small to meaningfully split

    final parts = <String>[];
    var remaining = w;

    while (remaining.length > width) {
      if (policy == LongWordPolicy.breakWithHyphen) {
        final cut = width - 1; // reserve 1 for hyphen
        parts.add("${remaining.substring(0, cut)}-");
        remaining = remaining.substring(cut);
      } else {
        // hardBreak
        parts.add(remaining.substring(0, width));
        remaining = remaining.substring(width);
      }
    }
    if (remaining.isNotEmpty) parts.add(remaining);
    return parts;
  }
}
