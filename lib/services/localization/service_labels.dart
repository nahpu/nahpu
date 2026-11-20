//! Display text for values that services return to the settings screens.
//!
//! Services describe what happened with typed values; this file turns them
//! into text in the UI language so the services stay free of UI wording.
import 'package:nahpu/services/database/database_health/database_health_models.dart';
import 'package:nahpu/services/export/export_progress.dart';
import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/settings/bundled_preset_service.dart';
import 'package:nahpu/services/settings/preset_transfer_service.dart';
import 'package:nahpu/services/types/file_explorer.dart';
import 'package:nahpu/services/types/file_format.dart';

extension NahpuLockReasonL10n on NahpuLockReason {
  /// Short phrase for the lock tooltip, phrased as what owns the file.
  String label(AppLocalizations l10n) => switch (this) {
    NahpuLockReason.database => l10n.fileExplorerLockDatabase,
    NahpuLockReason.databaseSidecar => l10n.fileExplorerLockDatabaseSidecar,
    NahpuLockReason.backup => l10n.fileExplorerLockBackup,
    NahpuLockReason.userConfig => l10n.fileExplorerLockUserConfig,
    NahpuLockReason.templateMedia => l10n.fileExplorerLockTemplateMedia,
    NahpuLockReason.mediaRecord => l10n.fileExplorerLockMediaRecord,
    NahpuLockReason.personnelPhoto => l10n.fileExplorerLockPersonnelPhoto,
    NahpuLockReason.associatedData => l10n.fileExplorerLockAssociatedData,
    NahpuLockReason.unresolvedReference =>
      l10n.fileExplorerLockUnresolvedReference,
    NahpuLockReason.recentlyModified => l10n.fileExplorerLockRecentlyModified,
    NahpuLockReason.unmanagedLocation => l10n.fileExplorerLockUnmanagedLocation,
    NahpuLockReason.unknownProject => l10n.fileExplorerLockUnknownProject,
  };
}

extension PruneBlockedReasonL10n on PruneBlockedReason {
  /// Why removing unlinked files is disabled for this scan.
  String message(AppLocalizations l10n) => switch (this) {
    PruneBlockedByUnresolvedReferences(:final count) =>
      l10n.fileExplorerPruneBlockedUnresolved(count),
    PruneBlockedByEmptyIndex() => l10n.fileExplorerPruneBlockedEmptyIndex,
  };
}

extension MediaKindCountL10n on MediaKind {
  /// [count] files of this kind, such as `2 images`.
  String countLabel(AppLocalizations l10n, int count) => switch (this) {
    MediaKind.image => l10n.fileExplorerImageCount(count),
    MediaKind.audio => l10n.fileExplorerAudioCount(count),
    MediaKind.video => l10n.fileExplorerVideoCount(count),
    MediaKind.other => l10n.fileExplorerOtherCount(count),
  };
}

extension ExportStepLabelL10n on ExportStepLabel {
  /// The stage name shown in the progress stepper.
  String text(AppLocalizations l10n) => switch (this) {
    ExportStepLabel.prepareBackup => l10n.progressPrepareBackup,
    ExportStepLabel.copyMediaAndFiles => l10n.progressCopyMediaAndFiles,
    ExportStepLabel.compressArchive => l10n.progressCompressArchive,
    ExportStepLabel.extractArchive => l10n.progressExtractArchive,
    ExportStepLabel.restoreMediaAndFiles => l10n.progressRestoreMediaAndFiles,
    ExportStepLabel.backUpCurrentData => l10n.progressBackUpCurrentData,
    ExportStepLabel.replaceDatabase => l10n.progressReplaceDatabase,
    ExportStepLabel.writeRecords => l10n.progressWriteRecords,
    ExportStepLabel.copyMedia => l10n.progressCopyMedia,
    ExportStepLabel.checkContents => l10n.progressCheckContents,
    ExportStepLabel.collectRecords => l10n.progressCollectRecords,
    ExportStepLabel.checkRecords => l10n.progressCheckRecords,
    ExportStepLabel.writeAndCompressPackage =>
      l10n.progressWriteAndCompressPackage,
    ExportStepLabel.processMedia => l10n.progressProcessMedia,
  };
}

extension BundledPresetLoadResultL10n on BundledPresetLoadResult {
  /// What loading bundled presets did, for a snackbar.
  String message(AppLocalizations l10n) {
    if (added.isNotEmpty) return l10n.serviceMessagePresetsAdded(added.length);
    return skippedCount == 0
        ? l10n.serviceMessageNoDefaultPresets
        : l10n.serviceMessageDefaultPresetsLoaded;
  }
}

extension DocumentPresetImportResultL10n on DocumentPresetImportResult {
  /// What importing a print layout file did, for a snackbar.
  String message(AppLocalizations l10n) {
    if (addedTemplateCount == 0) {
      return l10n.presetsImported(layoutNames.length);
    }
    return l10n.serviceMessagePresetsAndTemplatesImported(
      layoutNames.length,
      addedTemplateCount,
    );
  }
}

/// A note that [templateCount] templates use images that do not travel with
/// an exported file, or null when none do.
String? presetImageNote(AppLocalizations l10n, int templateCount) {
  if (templateCount == 0) return null;
  return l10n.serviceMessagePresetImageNote(templateCount);
}

extension HealthIssueKindL10n on HealthIssueKind {
  String title(AppLocalizations l10n) => switch (this) {
    HealthIssueKind.databaseIntegrity => l10n.healthKindDatabaseIntegrity,
    HealthIssueKind.brokenLink => l10n.healthKindBrokenLink,
    HealthIssueKind.crossProjectLink => l10n.healthKindCrossProjectLink,
    HealthIssueKind.missingMedia => l10n.healthKindMissingMedia,
    HealthIssueKind.missingPersonnelPhoto =>
      l10n.healthKindMissingPersonnelPhoto,
    HealthIssueKind.missingAttributeRecord =>
      l10n.healthKindMissingAttributeRecord,
    HealthIssueKind.fieldNumberConflict => l10n.healthKindFieldNumberConflict,
    HealthIssueKind.duplicateFieldNumber => l10n.healthKindDuplicateFieldNumber,
  };

  /// What the problem means and what to do about it.
  String help(AppLocalizations l10n) => switch (this) {
    HealthIssueKind.databaseIntegrity => l10n.healthKindDatabaseIntegrityHelp,
    HealthIssueKind.brokenLink => l10n.healthKindBrokenLinkHelp,
    HealthIssueKind.crossProjectLink => l10n.healthKindCrossProjectLinkHelp,
    HealthIssueKind.missingMedia => l10n.healthKindMissingMediaHelp,
    HealthIssueKind.missingPersonnelPhoto =>
      l10n.healthKindMissingPersonnelPhotoHelp,
    HealthIssueKind.missingAttributeRecord =>
      l10n.healthKindMissingAttributeRecordHelp,
    HealthIssueKind.fieldNumberConflict =>
      l10n.healthKindFieldNumberConflictHelp,
    HealthIssueKind.duplicateFieldNumber =>
      l10n.healthKindDuplicateFieldNumberHelp,
  };
}

extension HealthFixActionL10n on HealthFixAction? {
  String label(AppLocalizations l10n) => switch (this) {
    HealthFixAction.clearLink => l10n.healthFixClearLink,
    HealthFixAction.removeRow => l10n.healthFixRemoveRow,
    HealthFixAction.removeMissingMedia => l10n.healthFixRemoveMedia,
    HealthFixAction.clearPersonnelPhoto => l10n.healthFixClearPhoto,
    HealthFixAction.createAttributeRow => l10n.healthFixCreateAttributeRow,
    null => l10n.healthFixManual,
  };
}

extension HealthIssueL10n on HealthIssue {
  /// One line saying what is wrong with this record, or null when the
  /// section heading already says it.
  String? description(AppLocalizations l10n) => switch (kind) {
    HealthIssueKind.databaseIntegrity => detail,
    HealthIssueKind.brokenLink => l10n.healthIssueBrokenLink(
      databaseTableLabel(l10n, parentTable ?? ''),
    ),
    HealthIssueKind.crossProjectLink => l10n.healthIssueCrossProjectLink(
      databaseTableLabel(l10n, parentTable ?? ''),
    ),
    HealthIssueKind.duplicateFieldNumber => l10n.healthIssueDuplicateCount(
      int.tryParse(detail ?? '') ?? 0,
    ),
    HealthIssueKind.missingPersonnelPhoto => detail,
    _ => null,
  };
}

/// The display name of a database table, or the table name itself for one
/// users rarely see.
String databaseTableLabel(AppLocalizations l10n, String table) =>
    switch (table) {
      'project' => l10n.databaseTableProjects,
      'personnel' => l10n.databaseTablePersonnel,
      'taxonomy' => l10n.databaseTableTaxa,
      'site' => l10n.databaseTableSites,
      'collEvent' => l10n.databaseTableCollectionEvents,
      'specimen' => l10n.databaseTableSpecimens,
      'narrative' => l10n.databaseTableNarratives,
      'media' => l10n.databaseTableMediaRecords,
      _ => table,
    };
