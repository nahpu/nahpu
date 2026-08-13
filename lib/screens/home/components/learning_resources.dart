import 'package:material_ui/material_ui.dart';

class LearningResourcePage extends StatefulWidget {
  const LearningResourcePage({super.key});

  @override
  State<LearningResourcePage> createState() => _LearningResourcePageState();
}

class _LearningResourcePageState extends State<LearningResourcePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Resources'),
      ),
      body: const Center(
        child: Text('Coming soon...'),
      ),
    );
  }
}
