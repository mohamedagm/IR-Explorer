import 'package:flutter/material.dart';
import 'package:ir_explorer/ui/views/educational_view.dart';
import 'package:ir_explorer/ui/views/home_view.dart';

class IntroView extends StatelessWidget {
  const IntroView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'IR Explorer',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EducationalView(),
                        ),
                      );
                    },
                    child: const Text('Educational Path'),
                  ),
                ),

                const SizedBox(height: 16),

                // Go To Query
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomeView()),
                      );
                    },
                    child: const Text('Fast to Query'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
