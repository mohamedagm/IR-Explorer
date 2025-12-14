import 'package:ir_explorer/ir/inverted_index.dart';
import 'package:ir_explorer/services/text_processing.dart';

InvertedIndex buildIndex(Map<int, String> corpus) {
  final index = InvertedIndex();

  corpus.forEach((docId, text) {
    final terms = processText(text);
    for (var i = 0; i < terms.length; i++) {
      final term = terms[i];
      index.addTerm(term, docId, i);
    }
  });

  return index;
}
