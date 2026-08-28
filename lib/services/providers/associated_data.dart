import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/providers/database.dart';
import 'package:nahpu/services/types/associated_data.dart';

final associatedDataProvider = FutureProvider.family
    .autoDispose<List<AssociatedDataData>, AssociatedDataTarget>(
      (ref, target) => AssociatedDataQuery(
        ref.read(databaseProvider),
      ).getAssociatedDataForTarget(target),
    );
