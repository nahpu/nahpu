//! Display text for values that services return to the settings screens.
//!
//! Services describe what happened with typed values; this file turns them
//! into text in the UI language so the services stay free of UI wording.
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
