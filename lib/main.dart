import 'package:flutter/material.dart';
import 'package:ir_explorer/ir/corpus.dart';
import 'package:ir_explorer/ir/index_builder.dart';
import 'package:ir_explorer/ir/inverted_index.dart';
import 'package:ir_explorer/ir/retrieval/retrieval.dart';

void main() {
  final InvertedIndex index = buildIndex(corpus);

  print('--- Boolean AND ---');
  print(
    retrieve(
      index: index,
      type: RetrievalType.booleanAnd,
      query: 'learning project',
    ),
  );

  print('--- Boolean OR ---');
  print(
    retrieve(
      index: index,
      type: RetrievalType.booleanOr,
      query: 'search learning',
    ),
  );

  print('--- Boolean NOT ---');
  print(
    retrieve(
      index: index,
      type: RetrievalType.booleanNot,
      query: 'project',
      excludeQuery: 'cool',
    ),
  );

  print('--- Phrase Query ---');
  print(
    retrieve(index: index, type: RetrievalType.phrase, query: 'inverted index'),
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text('Testing IR Logic'))),
    );
  }
}
