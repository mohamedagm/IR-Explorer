import 'package:flutter/material.dart';
import 'package:ir_explorer/ir/corpus.dart';
import 'package:ir_explorer/ir/index_builder.dart';
import 'package:ir_explorer/ir/inverted_index.dart';
import 'package:ir_explorer/ir/retrieval/boolean_retrieval.dart';
import 'package:ir_explorer/ir/retrieval/phrase_retrieval.dart';
import 'package:ir_explorer/ir/soundex.dart';
import 'package:ir_explorer/services/stemmer.dart';
import 'package:ir_explorer/services/stopwords.dart';
import 'package:ir_explorer/services/tokenizer.dart';
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
  final ScrollController scrollController = ScrollController();

  SearchMode mode = SearchMode.booleanAnd;
  Set<int> results = {};

  final List<String> querySteps = [];
  bool isProcessing = false;
  bool isStepsExpanded = true;

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
      isStepsExpanded = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> runQueryStory(String query, String exclude) async {
    querySteps.clear();
    setState(() {
      isProcessing = true;
      isStepsExpanded = true;
    });

    Future<void> addStep(String text) async {
      setState(() => querySteps.add(text));
      await Future.delayed(const Duration(milliseconds: 400));
    }

    await addStep('User query: "$query"');

    await addStep('[Step 1] Tokenizing query');
    final tokens = tokenize(query);
    await addStep('→ Tokens:\n$tokens');

    await addStep('[Step 2] Removing stopwords');
    final afterStopWords = removeStopWords(tokens);
    await addStep('→ After stopwords:\n$afterStopWords');

    await addStep('[Step 3] Applying stemming');
    final afterStemming = applyStemming(afterStopWords);
    await addStep('→ After stemming:\n$afterStemming');

    switch (mode) {
      case SearchMode.booleanAnd:
        await addStep(
          '[Step 4] Using Boolean AND Retrieval Model (Inverted Index)',
        );
        break;

      case SearchMode.booleanOr:
        await addStep(
          '[Step 4] Using Boolean OR Retrieval Model (Inverted Index)',
        );
        break;

      case SearchMode.booleanNot:
        await addStep(
          '[Step 4] Using Boolean NOT Retrieval Model (Inverted Index)',
        );
        await addStep('→ Excluding terms: "$exclude"');
        break;

      case SearchMode.phrase:
        await addStep('[Step 4] Using Phrase Query Model (Positional Index)');
        break;

      case SearchMode.soundex:
        await addStep('[Step 4] Using Soundex Phonetic Search Model');
        break;
    }

    await addStep('[Step 5] Retrieving matching documents');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('IR Explorer'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: SearchModeDropdown(
                mode: mode,
                onChanged: (newMode) {
                  setState(() {
                    mode = newMode;
                    results.clear();
                  });
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            SliverToBoxAdapter(
              child: TextField(
                controller: queryController,
                decoration: InputDecoration(
                  labelText: _queryLabel(),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),

            if (mode == SearchMode.booleanNot) ...[
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: TextField(
                  controller: excludeController,
                  decoration: const InputDecoration(
                    labelText: 'Exclude terms',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            SliverToBoxAdapter(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: executeSearch,
                  child: const Text('Search'),
                ),
              ),
            ),

            if (querySteps.isNotEmpty) ...[
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(
                child: ExpansionTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.black),
                  ),
                  expansionAnimationStyle: AnimationStyle(curve: Curves.easeIn),
                  initiallyExpanded: isStepsExpanded,
                  onExpansionChanged: (value) {
                    setState(() => isStepsExpanded = value);
                  },
                  title: const Text(
                    'Query Processing Steps',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: [QuerySteps(querySteps: querySteps)],
                ),
              ),
            ],

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

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
