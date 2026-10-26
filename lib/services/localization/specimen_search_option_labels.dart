import 'package:nahpu/services/localization/l10n.dart';
import 'package:nahpu/services/types/specimens.dart';

/// Localized chip labels for [SpecimenSearchOption].
extension SpecimenSearchOptionLabel on SpecimenSearchOption {
  /// The search option in the UI language.
  String label(AppLocalizations l10n) => switch (this) {
    SpecimenSearchOption.all => l10n.formsSearchAll,
    SpecimenSearchOption.fieldNumber => l10n.formsSearchFieldNumber,
    SpecimenSearchOption.cataloger => l10n.formsSearchCataloger,
    SpecimenSearchOption.preparator => l10n.formsSearchPreparator,
    SpecimenSearchOption.collector => l10n.formsSearchCollector,
    SpecimenSearchOption.condition => l10n.formsSearchCondition,
    SpecimenSearchOption.prepDate => l10n.formsSearchPrepDate,
    SpecimenSearchOption.prepTime => l10n.formsSearchPrepTime,
    SpecimenSearchOption.taxa => l10n.formsSearchTaxa,
    SpecimenSearchOption.prepType => l10n.formsSearchPrepType,
  };
}
