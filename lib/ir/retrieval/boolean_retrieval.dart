import 'package:ir_explorer/ir/inverted_index.dart';
import 'package:ir_explorer/services/text_processing.dart';

Set<int> booleanAndQuery(InvertedIndex index, String query) {
  final terms = processText(query);
  if (terms.isEmpty) return {};

  Set<int>? result;

  for (final term in terms) {
    final docs = index.getDocs(term);
    result = result == null ? {...docs} : result.intersection(docs);
  }

  return result ?? {};
}

Set<int> booleanOrQuery(InvertedIndex index, String query) {
  final terms = processText(query);
  final result = <int>{};

  for (final term in terms) {
    result.addAll(index.getDocs(term));
  }

  return result;
}

Set<int> booleanNotQuery(
  InvertedIndex index,
  String includeQuery,
  String excludeQuery,
) {
  final includeDocs = booleanOrQuery(index, includeQuery);
  final excludeDocs = booleanOrQuery(index, excludeQuery);
  return includeDocs.difference(excludeDocs);
}
