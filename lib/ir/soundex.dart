import 'package:ir_explorer/ir/inverted_index.dart';
import 'package:ir_explorer/services/text_processing.dart';

String soundex(String input) {
  if (input.isEmpty) return '';

  final word = input.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
  if (word.isEmpty) return '';

  const Map<String, String> codes = {
    'B': '1',
    'F': '1',
    'P': '1',
    'V': '1',
    'C': '2',
    'G': '2',
    'J': '2',
    'K': '2',
    'Q': '2',
    'S': '2',
    'X': '2',
    'Z': '2',
    'D': '3',
    'T': '3',
    'L': '4',
    'M': '5',
    'N': '5',
    'R': '6',
  };
  final firstLetter = word[0];

  String? lastCode = codes[firstLetter];
  final buffer = StringBuffer()..write(firstLetter);

  for (var i = 1; i < word.length; i++) {
    final c = word[i];
    final code = codes[c] ?? '0';
    if (code != '0' && code != lastCode) {
      buffer.write(code);
      if (buffer.length == 4) break;
    }
    lastCode = code;
  }

  while (buffer.length < 4) {
    buffer.write('0');
  }

  return buffer.toString();
}

class SoundexIndex {
  final Map<String, List<String>> codeToTerms = {};

  void buildFromInvertedIndex(InvertedIndex index) {
    codeToTerms.clear();

    for (final term in index.postings.keys) {
      final code = soundex(term);
      if (code.isEmpty) continue;

      codeToTerms.putIfAbsent(code, () => <String>[]);

      if (!codeToTerms[code]!.contains(term)) {
        codeToTerms[code]!.add(term);
      }
    }
  }

  List<String> getTermsByCode(String code) {
    return codeToTerms[code] ?? <String>[];
  }

  List<String> searchSimilarTerms(String query) {
    final tokens = processText(query, enableStemming: false);
    if (tokens.isEmpty) return <String>[];

    final term = tokens.first;
    final code = soundex(term);
    if (code.isEmpty) return <String>[];

    final similar = getTermsByCode(code);
    return similar;
  }

  Set<int> searchDocsBySoundex(InvertedIndex index, String query) {
    final similarTerms = searchSimilarTerms(query);
    final result = <int>{};

    for (final term in similarTerms) {
      result.addAll(index.getDocs(term));
    }

    return result;
  }
}
