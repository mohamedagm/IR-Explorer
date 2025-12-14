import 'tokenizer.dart';
import 'stopwords.dart';
import 'stemmer.dart';

List<String> processText(String text, {bool enableStemming = true}) {
  final tokens = tokenize(text);
  final noStops = removeStopWords(tokens);
  final result = enableStemming ? applyStemming(noStops) : noStops;

  print('RAW TEXT: $text');
  print('TOKENS: $tokens');
  print('NO STOPWORDS: $noStops');
  print('FINAL (AFTER STEMMING): $result');
  print('-------------------------------');
  return result;
}

List<String> processQuery(String query) {
  return processText(query);
}
