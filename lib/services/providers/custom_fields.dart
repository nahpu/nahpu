import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/custom_fields/custom_field_service.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/types/custom_field.dart';
import 'package:nahpu/services/types/specimens.dart';

final customFieldServiceProvider = Provider<CustomFieldService>(
  (ref) => CustomFieldService(ref.watch(databaseProvider)),
);

typedef CustomFieldDefinitionFilter = ({
  FieldUISection placement,
  String? projectUuid,
  CatalogFmt? catalogFormat,
  bool includeArchived,
});

typedef CustomFieldSpecimenContext = ({
  FieldUISection placement,
  String specimenUuid,
});

final customFieldDefinitionsProvider = FutureProvider.autoDispose
    .family<List<CustomFieldDefinitionData>, CustomFieldDefinitionFilter>(
      (ref, filter) => ref
          .watch(customFieldServiceProvider)
          .getDefinitions(
            placement: filter.placement,
            projectUuid: filter.projectUuid,
            catalogFormat: filter.catalogFormat,
            includeArchived: filter.includeArchived,
          ),
    );

final manageableCustomFieldsProvider = FutureProvider.autoDispose
    .family<List<CustomFieldDefinitionData>, String?>(
      (ref, projectUuid) => ref
          .watch(customFieldServiceProvider)
          .getManageableDefinitions(projectUuid: projectUuid),
    );

final allCustomFieldDefinitionsProvider = FutureProvider.autoDispose(
  (ref) => ref.watch(customFieldServiceProvider).getAllDefinitions(),
);

final customFieldEntriesProvider = FutureProvider.autoDispose
    .family<List<CustomFieldEntry>, CustomFieldOwner>(
      (ref, owner) => ref.watch(customFieldServiceProvider).getEntries(owner),
    );

final customFieldSpecimenDefinitionsProvider = FutureProvider.autoDispose
    .family<List<CustomFieldDefinitionData>, CustomFieldSpecimenContext>(
      (ref, context) => ref
          .watch(customFieldServiceProvider)
          .getDefinitionsForSpecimenContext(
            placement: context.placement,
            specimenUuid: context.specimenUuid,
          ),
    );

final customFieldUsageProvider = FutureProvider.autoDispose
    .family<CustomFieldUsage, int>(
      (ref, definitionId) =>
          ref.watch(customFieldServiceProvider).getUsage(definitionId),
    );

void invalidateCustomFieldDefinitionProviders(WidgetRef ref) {
  ref.invalidate(customFieldDefinitionsProvider);
  ref.invalidate(customFieldSpecimenDefinitionsProvider);
  ref.invalidate(customFieldEntriesProvider);
  ref.invalidate(manageableCustomFieldsProvider);
  ref.invalidate(allCustomFieldDefinitionsProvider);
  ref.invalidate(customFieldUsageProvider);
}
