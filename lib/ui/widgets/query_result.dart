import 'package:flutter/material.dart';
import 'package:ir_explorer/ir/corpus.dart';

class QueryResult extends StatelessWidget {
  const QueryResult({super.key, required this.results});

  final Set<int> results;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const SliverToBoxAdapter(child: Center(child: Text('No results')));
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final docId = results.elementAt(index);

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 300),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text('Document $docId'),
              subtitle: Text(corpus[docId]!),
            ),
          ),
        );
      }, childCount: results.length),
    );
  }
}
