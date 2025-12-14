import 'package:flutter/material.dart';

class QuerySteps extends StatelessWidget {
  const QuerySteps({super.key, required this.querySteps});

  final List<String> querySteps;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: querySteps.map((step) {
          return Card(
            color: Colors.black,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                step,
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontFamily: 'monospace',
                  fontSize: 16,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
