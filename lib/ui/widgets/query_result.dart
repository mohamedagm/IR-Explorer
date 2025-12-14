import 'package:flutter/material.dart';
import 'package:ir_explorer/ir/corpus.dart';

class QueryResult extends StatelessWidget {
  const QueryResult({super.key, required this.results});

  final Set<int> results;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: results.isEmpty
          ? const Center(child: Text('No results'))
          : ListView(
              children: results.map((docId) {
                return Card(
                  child: ListTile(
                    title: Text('Document $docId'),
                    subtitle: Text(corpus[docId]!),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
