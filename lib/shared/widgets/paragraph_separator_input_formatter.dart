import 'package:flutter/services.dart';

/// Converts double-enter into a paragraph separator.
/// Example: "\n\n" can be customized.
class ParagraphSeparatorInputFormatter extends TextInputFormatter {
  ParagraphSeparatorInputFormatter({
    required this.separator,
  });

  final String separator;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // Only act when user is inserting text (not deletion)
    if (newValue.text.length <= oldValue.text.length) return newValue;

    // Detect the latest insertion
    final insertedLength = newValue.text.length - oldValue.text.length;
    if (insertedLength <= 0) return newValue;

    final cursor = newValue.selection.baseOffset;
    if (cursor < 0) return newValue;

    // We only care when user just inserted a "\n"
    // If user typed "\n\n" (double enter), replace the last two newlines with separator.
    // Also handle cases where they typed quickly and both newlines appear in one update.
    final text = newValue.text;

    // Check around cursor for double newline
    // Take a safe window ending at cursor
    final start = (cursor - 2).clamp(0, text.length);
    final end = cursor.clamp(0, text.length);
    final window = text.substring(start, end);

    if (window == "\n\n") {
      final before = text.substring(0, start);
      final after = text.substring(end);

      final replaced = before + separator + after;

      final newCursor = (before.length + separator.length);
      return TextEditingValue(
        text: replaced,
        selection: TextSelection.collapsed(offset: newCursor),
      );
    }

    // If both newlines came at once, cursor window may be larger,
    // check for trailing "\n\n" in a small region.
    final tailStart = (cursor - 10).clamp(0, text.length);
    final tail = text.substring(tailStart, cursor);
    if (tail.endsWith("\n\n")) {
      final cutAt = cursor - 2;
      final before = text.substring(0, cutAt);
      final after = text.substring(cursor);

      final replaced = before + separator + after;
      final newCursor = before.length + separator.length;

      return TextEditingValue(
        text: replaced,
        selection: TextSelection.collapsed(offset: newCursor),
      );
    }

    return newValue;
  }
}
