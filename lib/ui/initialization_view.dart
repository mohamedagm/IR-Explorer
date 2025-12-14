import 'package:flutter/material.dart';
import 'package:ir_explorer/ir/corpus.dart';
import 'package:ir_explorer/ir/index_builder.dart';
import 'package:ir_explorer/ir/inverted_index.dart';
import 'package:ir_explorer/ir/soundex.dart';
import 'package:ir_explorer/services/stemmer.dart';
import 'package:ir_explorer/services/stopwords.dart';
import 'package:ir_explorer/services/tokenizer.dart';
import 'package:ir_explorer/ui/home_view.dart';

class InitializationView extends StatefulWidget {
  const InitializationView({super.key});

  @override
  State<InitializationView> createState() => _InitializationViewState();
}

class _InitializationViewState extends State<InitializationView> {
  late InvertedIndex index;
  late SoundexIndex soundexIndex;
  final ScrollController scrollController = ScrollController();

  String title = '';
  String description = '';
  final List<String> outputLines = [];

  @override
  void initState() {
    super.initState();
    _startStory();
  }

  Future<void> _startStory() async {
    await _scene(
      titleText: 'Reading Documents',
      descriptionText: 'Reading raw documents from the corpus.',
      waitAfterDone: 1,
      buildOutput: () {
        final b = StringBuffer();
        corpus.forEach((id, text) {
          b.writeln('Doc $id: $text');
        });
        return b.toString();
      },
    );

    await _scene(
      titleText: 'Tokenization',
      descriptionText: 'Splitting documents into tokens.',
      waitAfterDone: 1,
      buildOutput: () {
        final b = StringBuffer();
        corpus.forEach((id, text) {
          b.writeln('Doc $id Tokens: ${tokenize(text)}');
        });
        return b.toString();
      },
    );

    await _scene(
      titleText: 'Stopword Removal',
      descriptionText: 'Removing common stopwords from tokens.',
      waitAfterDone: 1,
      buildOutput: () {
        final b = StringBuffer();
        corpus.forEach((id, text) {
          final tokens = tokenize(text);
          final filtered = removeStopWords(tokens);
          b.writeln('Doc $id After Stopwords: $filtered');
        });
        return b.toString();
      },
    );

    await _scene(
      titleText: 'Stemming',
      descriptionText: 'Reducing tokens to their root form.',
      waitAfterDone: 1,
      buildOutput: () {
        final b = StringBuffer();
        corpus.forEach((id, text) {
          final tokens = tokenize(text);
          final filtered = removeStopWords(tokens);
          final stemmed = applyStemming(filtered);
          b.writeln('Doc $id Stemmed: $stemmed');
        });
        return b.toString();
      },
    );

    index = buildIndex(corpus);

    await _scene(
      titleText: 'Inverted Index',
      descriptionText: 'Mapping terms to document IDs.',
      waitAfterDone: 1,
      buildOutput: () {
        final b = StringBuffer();
        index.postings.forEach((term, docs) {
          b.writeln('$term → $docs');
        });
        return b.toString();
      },
    );

    await _scene(
      titleText: 'Positional Index',
      descriptionText: 'Storing term positions inside documents.',
      waitAfterDone: 1,
      buildOutput: () {
        final b = StringBuffer();
        index.positional.forEach((term, pos) {
          b.writeln('$term → $pos');
        });
        return b.toString();
      },
    );

    soundexIndex = SoundexIndex();
    soundexIndex.buildFromInvertedIndex(index);

    await _scene(
      titleText: 'Soundex Index',
      descriptionText: 'Grouping phonetically similar terms.',
      waitAfterDone: 1,
      buildOutput: () {
        final b = StringBuffer();
        soundexIndex.codeToTerms.forEach((code, terms) {
          b.writeln('$code → $terms');
        });
        return b.toString();
      },
    );

    await _scene(
      titleText: 'System Ready',
      descriptionText: 'All preprocessing and indexing steps completed.',
      waitAfterDone: 1,
      buildOutput: () => '✔ IR Search Engine is ready.',
    );

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeView()),
    );
  }

  Future<void> _scene({
    required String titleText,
    required String descriptionText,
    required String Function() buildOutput,
    required int waitAfterDone,
  }) async {
    setState(() {
      title = titleText;
      description = descriptionText;
      outputLines.clear();
    });

    await Future.delayed(const Duration(seconds: 1));

    final fullOutput = buildOutput();
    final lines = fullOutput.split('\n');

    for (final line in lines) {
      if (!mounted) return;

      setState(() {
        outputLines.add(line);
      });

      // Auto scroll to bottom
      await Future.delayed(Duration(milliseconds: 700));
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }

    await Future.delayed(Duration(seconds: waitAfterDone));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IR System Initialization'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(description),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: outputLines.length,
                itemBuilder: (context, index) {
                  final line = outputLines[index];
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
                      color: Colors.black,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Text(
                          line,
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontFamily: 'monospace',
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
