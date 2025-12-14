import 'package:flutter/material.dart';

enum SearchMode { booleanAnd, booleanOr, booleanNot, phrase, soundex }

class SearchModeDropdown extends StatelessWidget {
  const SearchModeDropdown({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  final SearchMode mode;
  final ValueChanged<SearchMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<SearchMode>(
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
        DropdownMenuItem(value: SearchMode.phrase, child: Text('Phrase Query')),
        DropdownMenuItem(
          value: SearchMode.soundex,
          child: Text('Soundex Search'),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}
