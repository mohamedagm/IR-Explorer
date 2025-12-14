import 'package:flutter/material.dart';
import 'package:ir_explorer/ir/corpus.dart';
import 'package:ir_explorer/ir/index_builder.dart';
import 'package:ir_explorer/ir/inverted_index.dart';
import 'package:ir_explorer/ir/retrieval/boolean_retrieval.dart';
import 'package:ir_explorer/ir/retrieval/phrase_retrieval.dart';
import 'package:ir_explorer/ir/soundex.dart';

enum SearchMode { booleanAnd, booleanOr, booleanNot, phrase, soundex }

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late InvertedIndex index;
  late SoundexIndex soundexIndex;

  SearchMode mode = SearchMode.booleanAnd;

  final queryController = TextEditingController();
  final excludeController = TextEditingController();

  Set<int> results = {};

  @override
  void initState() {
    super.initState();
    index = buildIndex(corpus);
    soundexIndex = SoundexIndex();
    soundexIndex.buildFromInvertedIndex(index);
  }

  void executeSearch() {
    final query = queryController.text.trim();
    final exclude = excludeController.text.trim();

    if (query.isEmpty) return;

    Set<int> res = {};

    switch (mode) {
      case SearchMode.booleanAnd:
        res = booleanAndQuery(index, query);
        break;

      case SearchMode.booleanOr:
        res = booleanOrQuery(index, query);
        break;

      case SearchMode.booleanNot:
        if (exclude.isEmpty) return;
        res = booleanNotQuery(index, query, exclude);
        break;

      case SearchMode.phrase:
        res = phraseQuery(index, query);
        break;

      case SearchMode.soundex:
        res = soundexIndex.searchDocsBySoundex(index, query);
        break;
    }

    setState(() {
      results = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('IR Explorer'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          spacing: 16,
          children: [
            DropdownButton<SearchMode>(
              value: mode,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: SearchMode.booleanAnd,
                  child: Text('Boolean AND'),
                ),
                DropdownMenuItem(
                  value: SearchMode.booleanOr,
                  child: Text('Boolean OR'),
                ),
                DropdownMenuItem(
                  value: SearchMode.booleanNot,
                  child: Text('Boolean NOT'),
                ),
                DropdownMenuItem(
                  value: SearchMode.phrase,
                  child: Text('Phrase Query'),
                ),
                DropdownMenuItem(
                  value: SearchMode.soundex,
                  child: Text('Soundex Search'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  mode = value!;
                  results.clear();
                });
              },
            ),

            TextField(
              controller: queryController,
              decoration: InputDecoration(
                labelText: _queryLabel(),
                border: const OutlineInputBorder(),
              ),
            ),

            if (mode == SearchMode.booleanNot)
              TextField(
                controller: excludeController,
                decoration: const InputDecoration(
                  labelText: 'Exclude terms',
                  border: OutlineInputBorder(),
                ),
              ),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: executeSearch,
                child: const Text('Search'),
              ),
            ),

            Expanded(
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
            ),
          ],
        ),
      ),
    );
  }

  String _queryLabel() {
    switch (mode) {
      case SearchMode.booleanAnd:
        return 'Enter terms (AND)';
      case SearchMode.booleanOr:
        return 'Enter terms (OR)';
      case SearchMode.booleanNot:
        return 'Include terms';
      case SearchMode.phrase:
        return 'Enter phrase';
      case SearchMode.soundex:
        return 'Enter word (phonetic)';
    }
  }
}
