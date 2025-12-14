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

  String title = '';
  String description = '';
  String output = '';

  @override
  void initState() {
    super.initState();
    _startStory();
  }

  Future<void> _startStory() async {
    await _scene(
      titleText: 'Reading Documents',
      descriptionText: 'Reading raw documents from the corpus.',
      seconds: 4,
      buildOutput: () {
        final b = StringBuffer();
        corpus.forEach((id, text) {
          b.writeln('Doc $id: $text');
        });
        return b.toString();
      },
    );

    /// 2️⃣ Tokenization
    await _scene(
      titleText: 'Tokenization',
      descriptionText: 'Splitting documents into tokens.',
      seconds: 3,
      buildOutput: () {
        final b = StringBuffer();
        corpus.forEach((id, text) {
          b.writeln('Doc $id Tokens: ${tokenize(text)}');
        });
        return b.toString();
      },
    );

    /// 3️⃣ Stopword Removal
    await _scene(
      titleText: 'Stopword Removal',
      descriptionText: 'Removing common stopwords from tokens.',
      seconds: 3,
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

    /// 4️⃣ Stemming
    await _scene(
      titleText: 'Stemming',
      descriptionText: 'Reducing tokens to their root form.',
      seconds: 3,
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

    /// 5️⃣ Build Indexes
    index = buildIndex(corpus);

    await _scene(
      titleText: 'Inverted Index',
      descriptionText: 'Mapping terms to document IDs.',
      seconds: 4,
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
      seconds: 4,
      buildOutput: () {
        final b = StringBuffer();
        index.positional.forEach((term, pos) {
          b.writeln('$term → $pos');
        });
        return b.toString();
      },
    );

    /// 6️⃣ Soundex
    soundexIndex = SoundexIndex();
    soundexIndex.buildFromInvertedIndex(index);

    await _scene(
      titleText: 'Soundex Index',
      descriptionText: 'Grouping phonetically similar terms.',
      seconds: 4,
      buildOutput: () {
        final b = StringBuffer();
        soundexIndex.codeToTerms.forEach((code, terms) {
          b.writeln('$code → $terms');
        });
        return b.toString();
      },
    );

    /// 7️⃣ Ready
    await _scene(
      titleText: 'System Ready',
      descriptionText: 'All preprocessing and indexing steps completed.',
      seconds: 2,
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
    required int seconds,
  }) async {
    setState(() {
      title = titleText;
      description = descriptionText;
      output = 'Processing...';
    });

    await Future.delayed(const Duration(milliseconds: 600));

    setState(() {
      output = buildOutput();
    });

    await Future.delayed(Duration(seconds: seconds));
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
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    output,
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
