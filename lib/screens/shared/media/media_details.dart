import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/forms/forms.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/import/multimedia.dart';
import 'package:nahpu/services/media/media_linked_information_services.dart';
import 'package:nahpu/services/providers/personnel.dart';
import 'package:nahpu/services/types/import.dart';
import 'package:nahpu/services/localization/l10n.dart';

class MediaDetailsView extends ConsumerStatefulWidget {
  const MediaDetailsView({super.key, required this.media});

  final MediaData media;

  @override
  MediaDetailsViewState createState() => MediaDetailsViewState();
}

class MediaDetailsViewState extends ConsumerState<MediaDetailsView> {
  String? _mediaSize;
  bool _mediaSizeLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMediaSize();
  }

  @override
  void didUpdateWidget(covariant MediaDetailsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.media.fileName != widget.media.fileName ||
        oldWidget.media.category != widget.media.category ||
        oldWidget.media.projectUuid != widget.media.projectUuid) {
      setState(() {
        _mediaSize = null;
        _mediaSizeLoading = true;
      });
      _loadMediaSize();
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.media;
    final photographer = ref
        .watch(projectPersonnelProvider)
        .whenOrNull(
          data: (people) => people
              .where((person) => person.uuid == widget.media.personnelId)
              .firstOrNull
              ?.name,
        );
    final linkedInformation = ref.watch(
      mediaLinkedInformationProvider(
        MediaLinkRequest(
          mediaId: widget.media.primaryId,
          category: widget.media.category ?? '',
        ),
      ),
    );
    final sections = <_MediaDetailSection>[
      _MediaDetailSection(
        title: context.l10n.mediaDetailFile,
        rows: [
          MapEntry(context.l10n.sharedFileName, media.fileName),
          MapEntry(
            context.l10n.databaseSize,
            _mediaSizeLoading ? context.l10n.projectLoading : _mediaSize,
          ),
          MapEntry('URI', media.uri),
          MapEntry(context.l10n.mediaCategory, media.category),
        ],
      ),
      _MediaDetailSection(
        title: context.l10n.projectDescription,
        rows: [
          MapEntry(context.l10n.mediaCaption, media.caption),
          MapEntry(context.l10n.mediaTag, media.tag),
        ],
      ),
      _MediaDetailSection(
        title: context.l10n.mediaCaptureEquipment,
        rows: [
          MapEntry(context.l10n.mediaPhotographer, photographer),
          MapEntry(context.l10n.mediaTaken, _dateTaken(media.taken)),
          MapEntry(context.l10n.mediaCamera, media.camera),
          MapEntry(context.l10n.mediaLenses, media.lenses),
          MapEntry(context.l10n.mediaAdditionalExif, media.additionalExif),
        ],
      ),
      _MediaDetailSection(
        title: context.l10n.setupIdentifiers,
        rows: [
          MapEntry(context.l10n.mediaId, media.primaryId.toString()),
          MapEntry(context.l10n.mediaSecondaryId, media.secondaryId),
          MapEntry(context.l10n.recordsSpecimenProjectId, media.projectUuid),
          MapEntry(context.l10n.mediaPhotographerId, media.personnelId),
        ],
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          linkedInformation.when(
            data: (information) => information == null
                ? const SizedBox.shrink()
                : _MediaDetailSectionView(
                    section: _MediaDetailSection(
                      title: context.l10n.mediaLinkedInformation,
                      rows: information.fields
                          .map((field) => MapEntry(field.label, field.value))
                          .toList(growable: false),
                    ),
                  ),
            loading: () => FormSection(
              title: context.l10n.mediaLinkedInformation,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => FormSection(
              title: context.l10n.mediaLinkedInformation,
              child: Text(context.l10n.mediaLinkedInformationError('$error')),
            ),
          ),
          for (final section in sections)
            _MediaDetailSectionView(section: section),
        ],
      ),
    );
  }

  Future<void> _loadMediaSize() async {
    final media = widget.media;
    final fileName = media.fileName?.trim() ?? '';
    if (fileName.isEmpty) {
      _mediaSize = null;
      _mediaSizeLoading = false;
      return;
    }

    String? mediaSize;
    try {
      final file = await ImageServices(
        ref: ref,
        category: matchMediaCategoryString(media.category ?? ''),
      ).getProjectMediaPath(fileName, media.projectUuid ?? '');
      if (file.existsSync()) {
        mediaSize = formatMediaFileSize(file.lengthSync());
      }
    } catch (_) {
      mediaSize = null;
    }

    if (!mounted || widget.media != media) return;
    setState(() {
      _mediaSize = mediaSize;
      _mediaSizeLoading = false;
    });
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
