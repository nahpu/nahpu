import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/docs/documentation_repository.dart';

/// Bundled Day One artwork, synced from the NAHPU documentation site.
///
/// Asset keys always use `/`, whatever the host platform.
abstract final class DayOneFigureAssets {
  static const String directory = 'assets/docs/illustrations';
  static const String recordMap = '$directory/record-map.svg';
  static const String fieldTrail = '$directory/field-trail.svg';
  static const String geometry = '$directory/figures.json';
}

/// Which artwork a record-map node sits on, and so which colors it takes.
enum DayOneRecordTone { paper, project, place, record, shared }

class DayOneRecordBox {
  const DayOneRecordBox({
    required this.id,
    required this.tone,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final String id;
  final DayOneRecordTone tone;
  final double x;
  final double y;
  final double width;
  final double height;
}

class DayOneWaypoint {
  const DayOneWaypoint({required this.x, required this.y});

  final double x;
  final double y;
}

/// Where the tap targets of each Day One figure sit on its artwork, in the
/// artwork's own coordinates. The website reads the same file.
class DayOneFigures {
  const DayOneFigures({
    required this.recordMapWidth,
    required this.recordMapHeight,
    required this.recordBoxes,
    required this.trailWidth,
    required this.trailHeight,
    required this.waypoints,
  });

  factory DayOneFigures.fromJson(String source) {
    final json = jsonDecode(source) as Map<String, dynamic>;
    final recordMap = json['recordMap'] as Map<String, dynamic>;
    final trail = json['fieldTrail'] as Map<String, dynamic>;
    return DayOneFigures(
      recordMapWidth: _number(recordMap['width']),
      recordMapHeight: _number(recordMap['height']),
      recordBoxes: [
        for (final node in recordMap['nodes'] as List<dynamic>)
          _recordBox(node as Map<String, dynamic>),
      ],
      trailWidth: _number(trail['width']),
      trailHeight: _number(trail['height']),
      waypoints: [
        for (final point in trail['waypoints'] as List<dynamic>)
          DayOneWaypoint(
            x: _number((point as Map<String, dynamic>)['x']),
            y: _number(point['y']),
          ),
      ],
    );
  }

  final double recordMapWidth;
  final double recordMapHeight;
  final List<DayOneRecordBox> recordBoxes;
  final double trailWidth;
  final double trailHeight;
  final List<DayOneWaypoint> waypoints;

  static DayOneRecordBox _recordBox(Map<String, dynamic> node) {
    return DayOneRecordBox(
      id: node['id'] as String,
      tone: DayOneRecordTone.values.byName(node['tone'] as String),
      x: _number(node['x']),
      y: _number(node['y']),
      width: _number(node['w']),
      height: _number(node['h']),
    );
  }

  static double _number(Object? value) => (value as num).toDouble();
}

final dayOneFiguresProvider = FutureProvider<DayOneFigures>(
  (ref) => ref.watch(documentationRepositoryProvider).loadDayOneFigures(),
);

/// Practice steps opened from the Day One trail during this session.
class DayOneTrailVisitedNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() => const {};

  void visit(int index) {
    if (state.contains(index)) return;
    state = {...state, index};
  }
}

final dayOneTrailVisitedProvider =
    NotifierProvider<DayOneTrailVisitedNotifier, Set<int>>(
      DayOneTrailVisitedNotifier.new,
    );
