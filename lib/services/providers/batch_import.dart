import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/common/io_services.dart';
import 'package:nahpu/services/data_table/data_table_models.dart';
import 'package:nahpu/services/import/batch/batch_import_models.dart';
import 'package:nahpu/services/import/batch/batch_import_reader.dart';
import 'package:nahpu/services/import/batch/batch_import_service.dart';
import 'package:nahpu/services/import/batch/batch_import_targets.dart';
import 'package:nahpu/services/import/batch/batch_mapping_store.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/src/rust/api/dwc.dart' as rust_dwc;

typedef BatchImportFileReader =
    Future<BatchImportTable> Function(String filePath, {String? sheetName});

/// Reads the file a batch import starts from. Tests override it with fixed
/// tables, since reading goes through the Rust library.
final batchImportFileReaderProvider = Provider<BatchImportFileReader>(
  (ref) =>
      (filePath, {sheetName}) =>
          const BatchImportReader().readFile(filePath, sheetName: sheetName),
);

/// Darwin Core terms by field key for [DataTableRecordType]'s targets, from
/// the same mapping the Darwin Core export uses. Fields exported as
/// measurements or split over several terms are left out: a file column
/// can't name them by one term. When fields share a term, such as an
/// event's start and end dates, the first in picker order keeps it.
final batchDwcTermsProvider = FutureProvider.autoDispose
    .family<Map<String, String>, DataTableRecordType>((ref, type) async {
      final targets = batchImportTargets(type);
      final sources = {
        for (final target in targets)
          target.key: ?batchDwcSourceKey(target.key),
      };
      final headers = {
        for (final header in await rust_dwc.getDwcHeaders(
          sourceKeys: sources.values.toSet().toList(),
        ))
          if (header.headers.length == 1 && header.measurementType == null)
            header.sourceKey: header.headers.single,
      };
      return {
        for (final target in targets)
          target.key:
              ?(batchExtraDwcTerms[target.key] ?? headers[sources[target.key]]),
      };
    });

final batchMappingStoreProvider = Provider<BatchMappingStore>(
  (ref) => BatchMappingStore(ref.watch(settingProvider)),
);

typedef BatchImportReviewer =
    Future<BatchImportReview> Function(
      WidgetRef ref, {
      required BatchImportTable table,
      required DataTableRecordType type,
      required BatchImportMode mode,
      required List<BatchColumnMatch> matches,
      BatchImportKey? key,
    });

/// Reviews a batch import against the open project. The service takes a
/// [WidgetRef], so the wizard calls this with its own.
final batchImportReviewerProvider = Provider<BatchImportReviewer>(
  (ref) =>
      (
        widgetRef, {
        required table,
        required type,
        required mode,
        required matches,
        key,
      }) => BatchImportService(ref: widgetRef).review(
        table: table,
        type: type,
        mode: mode,
        matches: matches,
        key: key,
      ),
);

typedef BatchImportApplier =
    Future<BatchImportResult> Function(
      WidgetRef ref,
      BatchImportReview review, {
      bool includeMissingLinks,
      void Function(int done, int total)? onProgress,
    });

final batchImportApplierProvider = Provider<BatchImportApplier>(
  (ref) =>
      (widgetRef, review, {includeMissingLinks = true, onProgress}) =>
          BatchImportService(ref: widgetRef).apply(
            review,
            includeMissingLinks: includeMissingLinks,
            onProgress: onProgress,
          ),
);

/// Asks the user for the file to import. Tests override it.
final batchImportFilePickerProvider = Provider<Future<XFile?> Function()>(
  (ref) => FilePickerServices().selectAnyFile,
);
