import 'package:ir_explorer/ir/inverted_index.dart';
import 'boolean_retrieval.dart';
import 'phrase_retrieval.dart';

enum RetrievalType { booleanAnd, booleanOr, booleanNot, phrase }

Set<int> retrieve({
  required InvertedIndex index,
  required RetrievalType type,
  required String query,
  String? excludeQuery,
}) {
  switch (type) {
    case RetrievalType.booleanAnd:
      return booleanAndQuery(index, query);

    case RetrievalType.booleanOr:
      return booleanOrQuery(index, query);

    case RetrievalType.booleanNot:
      return booleanNotQuery(index, query, excludeQuery ?? '');

    case RetrievalType.phrase:
      return phraseQuery(index, query);
  }
}
