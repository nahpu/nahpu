import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/import/multimedia.dart';
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
    final rows = <MapEntry<String, String?>>[
      MapEntry('Media ID', media.primaryId.toString()),
      MapEntry('Secondary ID', media.secondaryId),
      MapEntry('Project ID', media.projectUuid),
      MapEntry('Category', media.category),
      MapEntry('Tag', media.tag),
      MapEntry('File name', media.fileName),
      MapEntry('URI', media.uri),
      MapEntry('Caption', media.caption),
      MapEntry('Photographer', photographer),
      MapEntry('Photographer ID', media.personnelId),
      MapEntry('Taken', _dateTaken(media.taken)),
      MapEntry('Camera', media.camera),
      MapEntry('Lenses', media.lenses),
      MapEntry('Additional EXIF', media.additionalExif),
    ];

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      itemCount: rows.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = rows[index];
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
      },
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
