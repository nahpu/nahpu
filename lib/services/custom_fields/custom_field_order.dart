import 'package:nahpu/services/database/database.dart';

/// Which ways a definition can move within its reorder group.
typedef CustomFieldMoves = ({bool canMoveUp, bool canMoveDown});

/// Ordering rules for custom field definitions in settings.
///
/// A definition is ordered only among its reorder group: the definitions that
/// share its placement, scope, and project.
abstract final class CustomFieldOrder {
  /// The definitions in [definition]'s reorder group, in the order of [all].
  static List<CustomFieldDefinitionData> reorderGroup(
    Iterable<CustomFieldDefinitionData> all,
    CustomFieldDefinitionData definition,
  ) {
    return all
        .where(
          (candidate) =>
              candidate.uiSection == definition.uiSection &&
              candidate.scope == definition.scope &&
              candidate.projectUuid == definition.projectUuid,
        )
        .toList();
  }

  /// Which ways [definition] can move among the [visible] definitions of its
  /// group, or null when it is alone there and there is nothing to reorder.
  static CustomFieldMoves? moves(
    List<CustomFieldDefinitionData> visible,
    CustomFieldDefinitionData definition,
  ) {
    final group = reorderGroup(visible, definition);
    final index = group.indexWhere((item) => item.id == definition.id);
    if (index < 0 || group.length < 2) return null;
    return (canMoveUp: index > 0, canMoveDown: index < group.length - 1);
  }

  /// The ids of [definition]'s whole group after moving it past its nearest
  /// [visible] neighbor, up when [offset] is negative and down otherwise.
  ///
  /// Hidden definitions, such as archived ones, keep their place, so a move is
  /// never spent passing a definition the user cannot see. Returns null when
  /// there is no neighbor in that direction.
  static List<int>? movedDefinitionIds({
    required List<CustomFieldDefinitionData> all,
    required List<CustomFieldDefinitionData> visible,
    required CustomFieldDefinitionData definition,
    required int offset,
  }) {
    if (offset == 0) return null;
    final visibleGroup = reorderGroup(visible, definition);
    final index = visibleGroup.indexWhere((item) => item.id == definition.id);
    final neighborIndex = index + offset.sign;
    if (index < 0 ||
        neighborIndex < 0 ||
        neighborIndex >= visibleGroup.length) {
      return null;
    }
    final neighborId = visibleGroup[neighborIndex].id;
    final ids = [
      for (final item in reorderGroup(all, definition))
        if (item.id != definition.id) item.id!,
    ];
    final target = ids.indexOf(neighborId!);
    if (target < 0) return null;
    ids.insert(offset < 0 ? target : target + 1, definition.id!);
    return ids;
  }
}
