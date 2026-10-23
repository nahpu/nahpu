import 'package:nahpu/services/database/specimen_queries.dart';
import 'package:nahpu/services/specimen_curation/tissue_box.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_service.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_settings.dart';
import 'package:nahpu/services/specimen_curation/tissue_entry.dart';

enum TissueScanStatus {
  checked,
  duplicate,
  notFound,
  conflict,
  skipped,
  invalid,
  undone;

  bool get isError => this == notFound || this == invalid;

  bool get isWarning =>
      this == duplicate || this == conflict || this == skipped;
}

/// What a scan or undo did, as shown to the user.
class TissueScanOutcome {
  const TissueScanOutcome(this.status, this.message);

  final TissueScanStatus status;
  final String message;
}

/// A tube checked into a box during this session.
class TissueCheckEntry {
  const TissueCheckEntry({
    required this.code,
    required this.label,
    required this.partId,
    required this.field,
    required this.value,
    required this.boxNumber,
    required this.cell,
    required this.location,
    this.previousValue,
    this.previousLocation,
  });

  final String code;

  /// The tissue ID, or the field ID with part type and treatment.
  final String label;
  final int partId;
  final TissueCheckField field;
  final String value;
  final int boxNumber;
  final TissueCell cell;
  final String location;
  final String? previousValue;
  final String? previousLocation;
}

/// Picks one part when a code matches several. Null skips the scan.
typedef TissuePartPicker =
    Future<SpecimenPartProjectRecord?> Function(
      List<SpecimenPartProjectRecord> records,
    );

/// Runs one tissue check: matches scans to parts, writes them to the next
/// free cell, and moves through the box. Scans run one at a time.
class TissueCheckSession {
  TissueCheckSession({
    required this.service,
    required this._settings,
    required this.saveSettings,
    this.onWrite,
  });

  final TissueCheckService service;
  final Future<void> Function(TissueCheckSettings settings) saveSettings;

  /// Called after the database changes, so part views can refresh.
  final void Function()? onWrite;

  TissueCheckSettings _settings;

  /// Part types and treatments that smart entry recognizes after an ID.
  List<String> partTypes = const [];
  List<String> treatments = const [];
  final Map<TissueCell, String?> _occupied = {};
  final List<TissueCheckEntry> _entries = [];
  TissueCell? _next;
  Future<void> _pending = Future.value();

  TissueCheckSettings get settings => _settings;
  TissueBoxLayout get layout => _settings.layout;

  /// Filled cells. The value is the tissue label when it was checked in
  /// this session, or null when an earlier check filled it.
  Map<TissueCell, String?> get occupied => Map.unmodifiable(_occupied);

  /// This session's checked tubes, newest first.
  List<TissueCheckEntry> get entries => List.unmodifiable(_entries.reversed);

  TissueCell? get next => _next;
  int get filledCount => _occupied.length;
  bool get isFull => _next == null;

  String? get nextLocation => _next == null
      ? null
      : formatTissueLocation(
          _settings.boxLabel,
          _settings.boxNumber,
          layout.cellLabel(_next!),
        );

  /// Reads which cells of the current box are already filled.
  Future<void> load() => _serial(_loadBox);

  /// Applies [settings] at once, then saves them and refills the box view
  /// when the box or its layout changed.
  Future<void> updateSettings(TissueCheckSettings settings) {
    final previous = _settings;
    _settings = settings;
    final reload =
        settings.layout.size != previous.layout.size ||
        settings.layout.numbering != previous.layout.numbering ||
        settings.layout.fillOrder != previous.layout.fillOrder ||
        settings.boxName != previous.boxName;
    return _serial(() async {
      await saveSettings(settings);
      if (reload) await _loadBox();
    });
  }

  /// Makes [cell] the next cell to fill when it is empty.
  void selectCell(TissueCell cell) {
    if (layout.contains(cell) && !_occupied.containsKey(cell)) {
      _next = cell;
    }
  }

  Future<void> nextBox() {
    return updateSettings(
      _settings.copyWith(boxNumber: _settings.boxNumber + 1),
    );
  }

  Future<TissueScanOutcome> scan(String code, {TissuePartPicker? pickPart}) {
    return _serial(() => _scan(code.trim(), pickPart));
  }

  /// Places [record] in the next cell without a scan, as the work list does.
  Future<TissueScanOutcome> place(SpecimenPartProjectRecord record) {
    return _serial(() async {
      await service.loadFieldIds();
      return _place(record, labelFor(record));
    });
  }

  /// Unplaced parts that match the type and treatment filters, in field ID
  /// order.
  Future<List<SpecimenPartProjectRecord>> workList() {
    return service.workList(
      partType: _settings.partType,
      preservation: _settings.preservation,
    );
  }

  /// How a part is named in messages and the log: its tissue ID, or its
  /// field ID with part type and treatment.
  String labelFor(SpecimenPartProjectRecord record) {
    final tissueId = record.part.tissueID?.trim() ?? '';
    if (tissueId.isNotEmpty) return tissueId;
    return [
      service.fieldIdOf(record.specimen.uuid),
      record.part.type ?? '',
      record.part.treatment ?? '',
    ].map((e) => e.trim()).where((e) => e.isNotEmpty).join(' · ');
  }

  /// Reverts the most recent check. Returns null when there is none.
  Future<TissueScanOutcome?> undoLast() {
    return _serial(() async {
      if (_entries.isEmpty) return null;
      final entry = _entries.removeLast();
      await service.revert(
        entry.partId,
        field: entry.field,
        value: entry.previousValue,
        location: entry.previousLocation,
      );
      onWrite?.call();
      if (entry.boxNumber != _settings.boxNumber) {
        _settings = _settings.copyWith(boxNumber: entry.boxNumber);
        await saveSettings(_settings);
        await _loadBox();
      } else {
        _occupied.remove(entry.cell);
      }
      _next = entry.cell;
      return TissueScanOutcome(
        TissueScanStatus.undone,
        'Undid ${entry.label} at ${entry.location}',
      );
    });
  }

  Future<TissueScanOutcome> _scan(
    String code,
    TissuePartPicker? pickPart,
  ) async {
    if (code.isEmpty) {
      return const TissueScanOutcome(
        TissueScanStatus.invalid,
        'Enter or scan a code first',
      );
    }
    final value = _settings.value.trim();
    if (value.isEmpty) {
      return TissueScanOutcome(
        TissueScanStatus.invalid,
        'Enter a value for ${_settings.field.label} first',
      );
    }
    final query = parseTissueEntry(
      code,
      types: partTypes,
      treatments: treatments,
    );
    final match = await service.find(
      query,
      identifyBy: _settings.identifyBy,
      partType: _settings.partType,
      preservation: _settings.preservation,
    );
    final SpecimenPartProjectRecord? record;
    switch (match.status) {
      case TissueMatchStatus.notFound:
        return TissueScanOutcome(
          TissueScanStatus.notFound,
          'Not found: $code. No cell used.',
        );
      case TissueMatchStatus.matched:
        record = match.records.single;
      case TissueMatchStatus.ambiguous:
        record = await pickPart?.call(match.records);
    }
    if (record == null) {
      return TissueScanOutcome(TissueScanStatus.skipped, 'Skipped: $code');
    }
    return _place(record, code);
  }

  Future<TissueScanOutcome> _place(
    SpecimenPartProjectRecord record,
    String code,
  ) async {
    final value = _settings.value.trim();
    if (value.isEmpty) {
      return TissueScanOutcome(
        TissueScanStatus.invalid,
        'Enter a value for ${_settings.field.label} first',
      );
    }
    final part = record.part;
    final label = labelFor(record).isEmpty ? code : labelFor(record);
    if (_entries.any((e) => e.partId == part.id)) {
      return TissueScanOutcome(
        TissueScanStatus.duplicate,
        'Already checked: $label',
      );
    }

    if (_next == null) {
      _settings = _settings.copyWith(boxNumber: _settings.boxNumber + 1);
      await saveSettings(_settings);
      await _loadBox();
      if (_next == null) {
        return TissueScanOutcome(
          TissueScanStatus.conflict,
          '${_settings.boxName} is full. Choose another box.',
        );
      }
    }

    final cell = _next!;
    final location = nextLocation!;
    final write = await service.apply(
      part,
      field: _settings.field,
      value: value,
      location: location,
      overwrite: _settings.overwrite,
    );
    if (write.status == TissueWriteStatus.conflict) {
      final where = write.previousLocation?.trim() ?? '';
      return TissueScanOutcome(
        TissueScanStatus.conflict,
        where.isNotEmpty
            ? '$label is already stored at $where. Turn on overwrite to move it.'
            : '$label already has ${_settings.field.label} '
                  '"${write.previousValue}". Turn on overwrite to replace it.',
      );
    }
    onWrite?.call();

    _entries.add(
      TissueCheckEntry(
        code: code,
        label: label,
        partId: part.id!,
        field: _settings.field,
        value: value,
        boxNumber: _settings.boxNumber,
        cell: cell,
        location: location,
        previousValue: write.previousValue,
        previousLocation: write.previousLocation,
      ),
    );
    _occupied[cell] = label;
    _next = layout.firstFree(_occupied.keys.toSet(), from: cell);
    return TissueScanOutcome(
      TissueScanStatus.checked,
      '$label → $location · ${_settings.field.label} = $value',
    );
  }

  Future<void> _loadBox() async {
    _occupied.clear();
    final locations = await service.locationsInBox(_settings.boxName);
    for (final location in locations) {
      final cell = parseTissueLocation(
        layout,
        boxLabel: _settings.boxLabel,
        boxNumber: _settings.boxNumber,
        location: location,
      );
      if (cell != null) _occupied[cell] = null;
    }
    for (final entry in _entries) {
      if (entry.boxNumber == _settings.boxNumber &&
          _occupied.containsKey(entry.cell)) {
        _occupied[entry.cell] = entry.label;
      }
    }
    _next = layout.firstFree(_occupied.keys.toSet());
  }

  Future<T> _serial<T>(Future<T> Function() operation) {
    final result = _pending.then((_) => operation());
    _pending = result.then<void>((_) {}, onError: (_) {});
    return result;
  }
}
