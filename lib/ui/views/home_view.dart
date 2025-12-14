import 'package:flutter/material.dart';
import 'package:ir_explorer/ir/corpus.dart';
import 'package:ir_explorer/ir/index_builder.dart';
import 'package:ir_explorer/ir/inverted_index.dart';
import 'package:ir_explorer/ir/retrieval/boolean_retrieval.dart';
import 'package:ir_explorer/ir/retrieval/phrase_retrieval.dart';
import 'package:ir_explorer/ir/soundex.dart';
import 'package:ir_explorer/ui/widgets/drop_down_button.dart';
import 'package:ir_explorer/ui/widgets/query_result.dart';
import 'package:ir_explorer/ui/widgets/query_steps.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late InvertedIndex index;
  late SoundexIndex soundexIndex;

  final queryController = TextEditingController();
  final excludeController = TextEditingController();
  SearchMode mode = SearchMode.booleanAnd;
  Set<int> results = {};

  final List<String> querySteps = [];
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    index = buildIndex(corpus);
    soundexIndex = SoundexIndex();
    soundexIndex.buildFromInvertedIndex(index);
  }

  Future<void> executeSearch() async {
    final query = queryController.text.trim();
    final exclude = excludeController.text.trim();
    if (query.isEmpty) return;

    await runQueryStory(query, exclude);

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
      isProcessing = false;
    });
  }

  Future<void> runQueryStory(String query, String exclude) async {
    querySteps.clear();
    setState(() => isProcessing = true);

    Future<void> addStep(String text) async {
      setState(() => querySteps.add(text));
      await Future.delayed(const Duration(milliseconds: 400));
    }

    await addStep('User query: "$query"');

    await addStep('Tokenizing query');
    final tokens = query.split(' ');
    await addStep('Tokens: $tokens');

    await addStep('Removing stopwords');
    await addStep('Applying stemming');

    await addStep('Retrieving matching documents');
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
            SearchModeDropdown(
              mode: mode,
              onChanged: (newMode) {
                setState(() {
                  mode = newMode;
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

            if (isProcessing || querySteps.isNotEmpty)
              QuerySteps(querySteps: querySteps),

            QueryResult(results: results),
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
