import 'dart:math' as math;

import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/types/import.dart';

enum MediaGallerySort {
  addedNewest,
  addedOldest,
  fileNameAscending,
  fileNameDescending,
  takenNewest,
  takenOldest,
}

extension MediaGallerySortLabel on MediaGallerySort {
  String get label => switch (this) {
    MediaGallerySort.addedNewest => 'Newest added',
    MediaGallerySort.addedOldest => 'Oldest added',
    MediaGallerySort.fileNameAscending => 'File name A–Z',
    MediaGallerySort.fileNameDescending => 'File name Z–A',
    MediaGallerySort.takenNewest => 'Date taken, newest',
    MediaGallerySort.takenOldest => 'Date taken, oldest',
  };
}

class MediaGalleryServices {
  const MediaGalleryServices();

  List<MediaData> filterAndSort({
    required Iterable<MediaData> media,
    required MediaCategory category,
    required String query,
    required MediaGallerySort sort,
    Map<String, String> personnelNames = const {},
  }) {
    final tokens = query
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toList(growable: false);
    final filtered = media.where((item) {
      if (category != MediaCategory.all &&
          item.category != matchMediaCategory(category)) {
        return false;
      }
      if (tokens.isEmpty) return true;
      final searchable = _searchableText(item, personnelNames).toLowerCase();
      return tokens.every(searchable.contains);
    }).toList();
    filtered.sort((left, right) => _compare(left, right, sort));
    return filtered;
  }

  String _searchableText(MediaData media, Map<String, String> personnelNames) {
    return <Object?>[
      media.primaryId,
      media.projectUuid,
      media.secondaryId,
      media.category,
      media.tag,
      media.taken,
      media.camera,
      media.lenses,
      media.additionalExif,
      media.personnelId,
      personnelNames[media.personnelId],
      media.fileName,
      media.uri,
      media.caption,
    ].whereType<Object>().join(' ');
  }

  int _compare(MediaData left, MediaData right, MediaGallerySort sort) {
    final comparison = switch (sort) {
      MediaGallerySort.addedNewest => right.primaryId.compareTo(left.primaryId),
      MediaGallerySort.addedOldest => left.primaryId.compareTo(right.primaryId),
      MediaGallerySort.fileNameAscending => _compareNames(
        left.fileName,
        right.fileName,
        descending: false,
      ),
      MediaGallerySort.fileNameDescending => _compareNames(
        left.fileName,
        right.fileName,
        descending: true,
      ),
      MediaGallerySort.takenNewest => _compareTaken(
        left.taken,
        right.taken,
        descending: true,
      ),
      MediaGallerySort.takenOldest => _compareTaken(
        left.taken,
        right.taken,
        descending: false,
      ),
    };
    return comparison != 0
        ? comparison
        : right.primaryId.compareTo(left.primaryId);
  }

  int _compareNames(String? left, String? right, {required bool descending}) {
    final blankComparison = _compareBlank(left, right);
    if (blankComparison != null) return blankComparison;
    final comparison = _compareNaturalText(
      left!.toLowerCase(),
      right!.toLowerCase(),
    );
    return descending ? -comparison : comparison;
  }

  int _compareTaken(String? left, String? right, {required bool descending}) {
    final leftDate = _parseTaken(left);
    final rightDate = _parseTaken(right);
    if (leftDate == null || rightDate == null) {
      if (leftDate == null && rightDate == null) return 0;
      return leftDate == null ? 1 : -1;
    }
    final comparison = leftDate.compareTo(rightDate);
    return descending ? -comparison : comparison;
  }

  int? _compareBlank(String? left, String? right) {
    final leftBlank = left == null || left.trim().isEmpty;
    final rightBlank = right == null || right.trim().isEmpty;
    if (!leftBlank && !rightBlank) return null;
    if (leftBlank == rightBlank) return 0;
    return leftBlank ? 1 : -1;
  }

  DateTime? _parseTaken(String? value) {
    final raw = value?.trim();
    if (raw == null || raw.isEmpty) return null;
    final match = RegExp(r'^(\d{4}):(\d{2}):(\d{2})(.*)$').firstMatch(raw);
    final normalized = match == null
        ? raw
        : '${match.group(1)}-${match.group(2)}-${match.group(3)}'
              '${match.group(4)}';
    return DateTime.tryParse(normalized);
  }

  int _compareNaturalText(String left, String right) {
    final leftParts = RegExp(
      r'\d+|\D+',
    ).allMatches(left).map((match) => match.group(0)!).toList(growable: false);
    final rightParts = RegExp(
      r'\d+|\D+',
    ).allMatches(right).map((match) => match.group(0)!).toList(growable: false);
    final length = math.min(leftParts.length, rightParts.length);
    for (var index = 0; index < length; index++) {
      final leftPart = leftParts[index];
      final rightPart = rightParts[index];
      final leftNumber = BigInt.tryParse(leftPart);
      final rightNumber = BigInt.tryParse(rightPart);
      final comparison = leftNumber != null && rightNumber != null
          ? leftNumber.compareTo(rightNumber)
          : leftPart.compareTo(rightPart);
      if (comparison != 0) return comparison;
    }
    return leftParts.length.compareTo(rightParts.length);
  }
}
