class InvertedIndex {
  final Map<String, Set<int>> postings = {};
  final Map<String, Map<int, List<int>>> positional = {};

  void addTerm(String term, int docId, int position) {
    postings.putIfAbsent(term, () => <int>{}).add(docId);
    positional.putIfAbsent(term, () => <int, List<int>>{});
    positional[term]!.putIfAbsent(docId, () => <int>[]);
    positional[term]![docId]!.add(position);
  }

  Set<int> allDocs() {
    final result = <int>{};
    for (final docs in postings.values) {
      result.addAll(docs);
    }
    return result;
  }

  Set<int> getDocs(String term) {
    return postings[term] ?? <int>{};
  }

  Map<int, List<int>> getPositions(String term) {
    return positional[term] ?? <int, List<int>>{};
  }
}
