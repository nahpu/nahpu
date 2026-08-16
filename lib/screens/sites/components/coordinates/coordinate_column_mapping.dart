part of '../coordinates.dart';

typedef CoordinateImportMappingChanged =
    void Function(CoordinateImportField field, int? column);

class CoordinateColumnMapping extends StatelessWidget {
  const CoordinateColumnMapping({
    super.key,
    required this.data,
    required this.mapping,
    required this.onMappingChanged,
    required this.onReview,
    required this.onChooseAnother,
    this.errorText,
  });

  final CoordinateTabularData data;
  final Map<CoordinateImportField, int?> mapping;
  final CoordinateImportMappingChanged onMappingChanged;
  final VoidCallback onReview;
  final VoidCallback onChooseAnother;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final worksheet = data.worksheetName;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Text(
          'Match columns',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          '${data.headers.length} columns and ${data.rows.length} data rows detected'
          '${worksheet == null ? '' : ' in worksheet "$worksheet"'}. '
          'NAHPU inferred the matches below. Latitude and longitude are required; all other fields are optional.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        for (final field in CoordinateImportField.values) ...[
          DropdownButtonFormField<int?>(
            key: ValueKey('coordinate-import-${field.name}'),
            initialValue: mapping[field],
            isExpanded: true,
            decoration: InputDecoration(
              labelText: '${field.label}${field.isRequired ? ' *' : ''}',
            ),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: CommonDropdownText(text: 'Not included'),
              ),
              for (var index = 0; index < data.headers.length; index++)
                DropdownMenuItem<int?>(
                  value: index,
                  child: CommonDropdownText(
                    text: '${data.headers[index]} (column ${index + 1})',
                  ),
                ),
            ],
            onChanged: (column) => onMappingChanged(field, column),
          ),
          const SizedBox(height: 12),
        ],
        if (errorText case final error?) ...[
          Text(
            error,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Align(
          alignment: Alignment.center,
          child: FilledButton.icon(
            onPressed: onReview,
            icon: const Icon(Icons.preview_outlined),
            label: const Text('Review coordinates'),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.center,
          child: TextButton(
            onPressed: onChooseAnother,
            child: const Text('Choose another file'),
          ),
        ),
      ],
    );
  }
}
