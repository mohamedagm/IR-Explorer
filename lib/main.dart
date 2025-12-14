import 'package:flutter/material.dart';
import 'package:ir_explorer/ir/corpus.dart';
import 'package:ir_explorer/ir/index_builder.dart';
import 'package:ir_explorer/ir/inverted_index.dart';
import 'package:ir_explorer/ir/soundex.dart';

void main() {
  final InvertedIndex index = buildIndex(corpusSoundex);

  final soundexIndex = SoundexIndex();
  soundexIndex.buildFromInvertedIndex(index);

  print('--- Soundex Terms ---');
  print(soundexIndex.searchSimilarTerms('retrievals'));

  print('--- Soundex Docs ---');
  print(soundexIndex.searchDocsBySoundex(index, 'retrievals'));

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
