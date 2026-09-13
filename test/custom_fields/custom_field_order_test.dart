import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/custom_fields/custom_field_order.dart';
import 'package:nahpu/services/database/database.dart';

void main() {
  group('reorderGroup', () {
    test('keeps only definitions sharing placement, scope, and project', () {
      final first = _definition(1, scope: 'project', projectUuid: 'a');
      final all = [
        first,
        _definition(2, scope: 'project', projectUuid: 'b'),
        _definition(3),
        _definition(4, uiSection: 'parasite', scope: 'project'),
        _definition(5, scope: 'project', projectUuid: 'a'),
      ];

      final group = CustomFieldOrder.reorderGroup(all, first);

      expect(group.map((item) => item.id), [1, 5]);
    });
  });

  group('moves', () {
    test('is null when the definition is alone in its group', () {
      final alone = _definition(1);
      final visible = [alone, _definition(2, scope: 'project')];

      expect(CustomFieldOrder.moves(visible, alone), isNull);
    });

    test('allows only the directions with a neighbor', () {
      final visible = [_definition(1), _definition(2), _definition(3)];

      expect(CustomFieldOrder.moves(visible, visible.first), (
        canMoveUp: false,
        canMoveDown: true,
      ));
      expect(CustomFieldOrder.moves(visible, visible[1]), (
        canMoveUp: true,
        canMoveDown: true,
      ));
      expect(CustomFieldOrder.moves(visible, visible.last), (
        canMoveUp: true,
        canMoveDown: false,
      ));
    });
  });

  group('movedDefinitionIds', () {
    test('returns null when there is no neighbor that way', () {
      final all = [_definition(1), _definition(2)];

      expect(
        CustomFieldOrder.movedDefinitionIds(
          all: all,
          visible: all,
          definition: all.first,
          offset: -1,
        ),
        isNull,
      );
      expect(
        CustomFieldOrder.movedDefinitionIds(
          all: all,
          visible: all,
          definition: all.last,
          offset: 1,
        ),
        isNull,
      );
    });

    test('swaps with the adjacent definition', () {
      final all = [_definition(1), _definition(2), _definition(3)];

      expect(
        CustomFieldOrder.movedDefinitionIds(
          all: all,
          visible: all,
          definition: all.first,
          offset: 1,
        ),
        [2, 1, 3],
      );
      expect(
        CustomFieldOrder.movedDefinitionIds(
          all: all,
          visible: all,
          definition: all.last,
          offset: -1,
        ),
        [1, 3, 2],
      );
    });

    test('passes hidden archived definitions in one move', () {
      final all = [
        _definition(1),
        _definition(2, archived: true),
        _definition(3),
      ];
      final visible = [all.first, all.last];

      expect(
        CustomFieldOrder.movedDefinitionIds(
          all: all,
          visible: visible,
          definition: all.last,
          offset: -1,
        ),
        [3, 1, 2],
      );
      expect(
        CustomFieldOrder.movedDefinitionIds(
          all: all,
          visible: visible,
          definition: all.first,
          offset: 1,
        ),
        [2, 3, 1],
      );
    });
  });
}

CustomFieldDefinitionData _definition(
  int id, {
  String uiSection = 'siteAttribute',
  String scope = 'global',
  String? projectUuid,
  bool archived = false,
}) {
  return CustomFieldDefinitionData(
    id: id,
    uuid: 'definition-$id',
    name: 'Field $id',
    type: 'text',
    uiSection: uiSection,
    scope: scope,
    projectUuid: projectUuid,
    sortOrder: id,
    isArchived: archived ? 1 : 0,
    allowDwcConflict: 0,
  );
}
