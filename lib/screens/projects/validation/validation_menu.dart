import 'package:flutter/material.dart';
import 'package:nahpu/screens/projects/validation/specimen_validation/specimen_validation_view.dart';

class ValidationMenu extends StatelessWidget {
  const ValidationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Validation'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.catching_pokemon),
                    title: const Text('Specimen Records'),
                    subtitle: const Text(
                        'Check for statistical outliers and missing mandatory fields'),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const SpecimenValidationView(),
                        ),
                      );
                    },
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.place_outlined),
                    title: const Text('Site Records'),
                    subtitle: const Text('Check for missing mandatory fields'),
                    enabled: false,
                    onTap: () {
                      // TODO: Implement site validation
                    },
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