import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/providers/page_jump.dart';
import 'package:nahpu/services/types/record_sort.dart';

extension RecordSortFieldLabel on RecordSortField {
  /// The sort dialog's label for this field in [viewer], in the UI language.
  ///
  /// [RecordSortField.insertion] reads "ID" where the record carries a visible
  /// integer id, and "Record order" for specimens, whose key is a uuid.
  String localizedLabelFor(RecordViewer viewer, AppLocalizations l10n) {
    return switch (this) {
      RecordSortField.insertion =>
        viewer == RecordViewer.specimen
            ? l10n.sharedSortRecordOrder
            : l10n.sharedSortId,
      RecordSortField.siteName => l10n.sharedSortSiteId,
      RecordSortField.stateProvince => l10n.sharedSortStateProvince,
      RecordSortField.locality => l10n.sharedSortPreciseLocality,
      RecordSortField.eventId => l10n.sharedSortEventId,
      RecordSortField.startDate => l10n.sharedSortStartDate,
      RecordSortField.fieldId => l10n.sharedSortFieldId,
      RecordSortField.cataloger => l10n.sharedSortCataloger,
      RecordSortField.species => l10n.sharedSortSpecies,
      RecordSortField.narrativeDate => l10n.sharedSortDate,
      RecordSortField.narrativeSite => l10n.sharedSortSiteId,
      RecordSortField.writer => l10n.sharedSortWriter,
    };
  }
}

extension RecordSortDirectionLabel on RecordSortDirection {
  /// The sort dialog's label for this direction, in the UI language.
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    RecordSortDirection.ascending => l10n.sharedSortAscending,
    RecordSortDirection.descending => l10n.sharedSortDescending,
  };
}
