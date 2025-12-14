import 'package:ir_explorer/ir/inverted_index.dart';
import 'package:ir_explorer/services/text_processing.dart';
import 'boolean_retrieval.dart';

Set<int> phraseQuery(InvertedIndex index, String phrase) {
  final terms = processText(phrase);
  if (terms.isEmpty) return {};
  if (terms.length == 1) {
    return booleanAndQuery(index, phrase);
  }

  final result = <int>{};
  final firstTerm = terms.first;
  final firstPositions = index.getPositions(firstTerm);

  firstPositions.forEach((docId, basePositions) {
    for (final basePos in basePositions) {
      bool match = true;

      for (var i = 1; i < terms.length; i++) {
        final positions = index.getPositions(terms[i])[docId];
        if (positions == null || !positions.contains(basePos + i)) {
          match = false;
          break;
        }
      }

      if (match) {
        result.add(docId);
        break;
      }
    }
  });

  return result;
}
