List<String> tokenize(String text) {
  final lower = text.toLowerCase();

  final cleaned = lower.replaceAll(
    RegExp(r'[^\p{L}\p{N}\s]+', unicode: true),
    ' ',
  );

  final tokens = cleaned
      .split(RegExp(r'\s+'))
      .where((t) => t.isNotEmpty)
      .toList();
  return tokens;
}
