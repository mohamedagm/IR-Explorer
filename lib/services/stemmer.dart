String stem(String word) {
  if (word.length <= 3) return word;

  final suffixes = [
    'ing',
    'ed',
    'es',
    's',
    'ly',
    'tion',
    'tions',
    'ion',
    'ions',
  ];

  for (final suf in suffixes) {
    if (word.endsWith(suf) && word.length > suf.length + 2) {
      return word.substring(0, word.length - suf.length);
    }
  }

  return word;
}

List<String> applyStemming(List<String> tokens) {
  return tokens.map(stem).toList();
}
