String shortPreview(String text, {int max = 140}) {
  final t = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (t.length <= max) return t;
  return '${t.substring(0, max)}…';
}
