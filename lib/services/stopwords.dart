const Set<String> stopWords = {
  'the',
  'is',
  'am',
  'are',
  'was',
  'were',
  'a',
  'an',
  'and',
  'or',
  'to',
  'of',
  'in',
  'on',
  'for',
  'with',
  'at',
  'by',
  'from',
  'this',
  'that',
  'it',
  'as',
  'be',
  'been',
  'about',
};

List<String> removeStopWords(List<String> tokens) {
  return tokens.where((t) => !stopWords.contains(t)).toList();
}
