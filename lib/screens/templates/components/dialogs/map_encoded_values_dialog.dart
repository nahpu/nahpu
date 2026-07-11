import 'package:flutter/material.dart';

class _EncodedMapping {
  _EncodedMapping({required this.key, required this.controller});
  final String key;
  final TextEditingController controller;
}

class MapEncodedValuesDialog extends StatefulWidget {
  const MapEncodedValuesDialog({
    super.key,
    required this.placeholderKey,
    required this.currentOption,
  });

  final String placeholderKey;
  final String currentOption;

  @override
  State<MapEncodedValuesDialog> createState() => _MapEncodedValuesDialogState();
}

class _MapEncodedValuesDialogState extends State<MapEncodedValuesDialog> {
  final List<_EncodedMapping> _mappings = [];

  @override
  void initState() {
    super.initState();
    final parsedMap = _parseCustomMap(widget.currentOption);
    final defaultMap = _getDefaultEnumMapForPlaceholder(widget.placeholderKey);

    final keys = <String>{...defaultMap.keys, ...parsedMap.keys}.toList()
      ..sort((a, b) {
        final na = int.tryParse(a);
        final nb = int.tryParse(b);
        if (na != null && nb != null) return na.compareTo(nb);
        return a.compareTo(b);
      });

    if (keys.isEmpty) {
      keys.addAll(['0', '1', '2', '3']);
    }

    for (final k in keys) {
      final currentVal = parsedMap[k] ?? defaultMap[k] ?? '';
      _mappings.add(
        _EncodedMapping(
          key: k,
          controller: TextEditingController(text: currentVal),
        ),
      );
    }
  }

  @override
  void dispose() {
    for (final item in _mappings) {
      item.controller.dispose();
    }
    super.dispose();
  }

  Map<String, String> _parseCustomMap(String formatOption) {
    if (!formatOption.startsWith('custom_map:')) return {};
    final mapStr = formatOption.substring(11);
    final map = <String, String>{};
    for (final pair in mapStr.split(',')) {
      final parts = pair.split('=');
      if (parts.length == 2) {
        map[parts[0].trim()] = parts[1].trim();
      }
    }
    return map;
  }

  String? _cleanPlaceholderKey(String rawKey) {
    final clean = rawKey.trim().toLowerCase();
    if (clean.isEmpty) return null;
    return clean;
  }

  Map<String, String> _getDefaultEnumMapForPlaceholder(String key) {
    final cleanKey = _cleanPlaceholderKey(key);
    if (cleanKey == null) return {};

    if (cleanKey.endsWith('::sex')) {
      return {'0': 'Male', '1': 'Female', '2': 'Unknown'};
    } else if (cleanKey == 'mammalmeasurement::age') {
      return {'0': 'Adult', '1': 'Subadult', '2': 'Juvenile', '3': 'Unknown'};
    } else if (cleanKey == 'herpmeasurement::age') {
      return {
        '0': 'Adult',
        '1': 'Juvenile',
        '2': 'Neonate',
        '3': 'Metamorph',
        '4': 'Unknown'
      };
    } else if (cleanKey.endsWith('::testisposition')) {
      return {'0': 'Scrotal', '1': 'Abdominal'};
    } else if (cleanKey.endsWith('::epididymisappearance')) {
      return {'0': 'Tubular', '1': 'Partial', '2': 'Not Tubular'};
    } else if (cleanKey.endsWith('::vaginaopening')) {
      return {'0': 'Imperforate', '1': 'Perforate'};
    } else if (cleanKey.endsWith('::pubicsymphysis')) {
      return {'0': 'Close', '1': 'Small Open', '2': 'Open'};
    } else if (cleanKey.endsWith('::reproductivestage')) {
      return {'0': 'Nulliparous', '1': 'Primiparous', '2': 'Multiparous'};
    } else if (cleanKey.endsWith('::mammaecondition')) {
      return {'0': 'Small', '1': 'Large', '2': 'Lactating'};
    } else if (cleanKey.endsWith('::ovaryappearance')) {
      return {'0': 'Smooth', '1': 'Small', '2': 'At least one ovum >1 mm'};
    } else if (cleanKey.endsWith('::oviductappearance')) {
      return {'0': 'Straight', '1': 'Convoluted'};
    } else if (cleanKey.endsWith('::fat')) {
      return {
        '0': 'No Fat',
        '1': 'Trace',
        '2': 'Light',
        '3': 'Moderate',
        '4': 'Heavy',
        '5': 'Extremely Heavy'
      };
    } else if (cleanKey.endsWith('::bodymolt')) {
      return {
        '0': 'None',
        '1': 'Trace',
        '2': 'Light',
        '3': 'Moderate',
        '4': 'Heavy'
      };
    } else if (cleanKey.endsWith('::echolocation')) {
      return {'0': 'FM', '1': 'CF', '2': 'QCF', '3': 'None'};
    } else if (cleanKey.endsWith('::broodpatch') ||
        cleanKey.endsWith('::hasbursa') ||
        cleanKey.endsWith('::wingismolt') ||
        cleanKey.endsWith('::tailismolt') ||
        cleanKey.endsWith('::showbatfields') ||
        cleanKey.endsWith('::showechofields')) {
      return {'0': 'No', '1': 'Yes'};
    }
    return {};
  }

  void _onSave() {
    final pairs =
        _mappings.map((e) => '${e.key}=${e.controller.text.trim()}').join(',');
    Navigator.pop(context, 'custom_map:$pairs');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Map Encoded Values'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.placeholderKey.isNotEmpty) ...[
              Text(
                'Define custom labels for [${widget.placeholderKey}] values:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
            ],
            for (final item in _mappings) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Text(
                        '${item.key}:',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: item.controller,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _onSave,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
