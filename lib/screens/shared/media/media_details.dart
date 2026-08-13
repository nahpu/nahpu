import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/import/multimedia.dart';
import 'package:nahpu/services/media/media_linked_information_services.dart';
import 'package:nahpu/services/providers/personnel.dart';

class MediaDetailsView extends ConsumerWidget {
  const MediaDetailsView({super.key, required this.media});

  final MediaData media;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photographer = ref
        .watch(projectPersonnelProvider)
        .whenOrNull(
          data: (people) => people
              .where((person) => person.uuid == media.personnelId)
              .firstOrNull
              ?.name,
        );
    final linkedInformation = ref.watch(
      mediaLinkedInformationProvider(
        MediaLinkRequest(
          mediaId: media.primaryId,
          category: media.category ?? '',
        ),
      ),
    );
    final sections = <_MediaDetailSection>[
      _MediaDetailSection(
        title: 'File',
        rows: [
          MapEntry('File name', media.fileName),
          MapEntry('URI', media.uri),
          MapEntry('Category', media.category),
        ],
      ),
      _MediaDetailSection(
        title: 'Description',
        rows: [MapEntry('Caption', media.caption), MapEntry('Tag', media.tag)],
      ),
      _MediaDetailSection(
        title: 'Capture and equipment',
        rows: [
          MapEntry('Photographer', photographer),
          MapEntry('Taken', _dateTaken(media.taken)),
          MapEntry('Camera', media.camera),
          MapEntry('Lenses', media.lenses),
          MapEntry('Additional EXIF', media.additionalExif),
        ],
      ),
      _MediaDetailSection(
        title: 'Identifiers',
        rows: [
          MapEntry('Media ID', media.primaryId.toString()),
          MapEntry('Secondary ID', media.secondaryId),
          MapEntry('Project ID', media.projectUuid),
          MapEntry('Photographer ID', media.personnelId),
        ],
      ),
    ];

    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      children: [
        linkedInformation.when(
          data: (information) => information == null
              ? const SizedBox.shrink()
              : _MediaDetailSectionView(
                  section: _MediaDetailSection(
                    title: 'Linked information',
                    rows: information.fields
                        .map((field) => MapEntry(field.label, field.value))
                        .toList(growable: false),
                  ),
                ),
          loading: () => const FormSection(
            title: 'Linked information',
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => FormSection(
            title: 'Linked information',
            child: Text('Linked information is unavailable: $error'),
          ),
        ),
        for (final section in sections)
          _MediaDetailSectionView(section: section),
      ],
    );
  }

  String _dateTaken(String? rawValue) {
    final value = parseMediaDateTime(rawValue ?? '');
    if (value.date.isEmpty && value.time.isEmpty) {
      return rawValue ?? '';
    }
    return '${value.date} ${value.time}'.trim();
  }
}

class _MediaDetailSectionView extends StatelessWidget {
  const _MediaDetailSectionView({required this.section});

  final _MediaDetailSection section;

  @override
  Widget build(BuildContext context) {
    return FormSection(
      title: section.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (rowIndex, entry) in section.rows.indexed) ...[
            if (rowIndex > 0) const SizedBox(height: 12),
            _MediaDetailRow(entry: entry),
          ],
        ],
      ),
    );
  }
}

class _MediaDetailSection {
  const _MediaDetailSection({required this.title, required this.rows});

  final String title;
  final List<MapEntry<String, String?>> rows;
}

class _MediaDetailRow extends StatelessWidget {
  const _MediaDetailRow({required this.entry});

  final MapEntry<String, String?> entry;

  @override
  Widget build(BuildContext context) {
    final value = entry.value?.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          entry.key,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        SelectableText(
          value == null || value.isEmpty ? 'Not set' : value,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
