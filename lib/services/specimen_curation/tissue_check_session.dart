import 'package:nahpu/services/specimen_curation/tissue_box.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_service.dart';
import 'package:nahpu/services/specimen_curation/tissue_check_settings.dart';
import 'package:nahpu/services/specimen_curation/tissue_entry.dart';
import 'package:nahpu/services/specimen_curation/tissue_item.dart';

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
    required this.kind,
    required this.itemId,
    required this.field,
    required this.value,
    required this.boxNumber,
    required this.cell,
    required this.location,
    this.previousValue,
    this.previousLocation,
  });

  final String code;

  /// The tissue or parasite ID, or the field ID with part type and
  /// treatment.
  final String label;
  final TissueItemKind kind;

  /// The part or parasite id, depending on [kind].
  final int itemId;
  final TissueCheckField field;
  final String value;
  final int boxNumber;
  final TissueCell cell;
  final String location;
  final String? previousValue;
  final String? previousLocation;
}

/// A tube passed over during this session: skipped on the work list, or a
/// scan whose match picker was dismissed. Placing the tube later removes it.
class TissueSkipEntry {
  const TissueSkipEntry({required this.label, this.key});

  final String label;

  /// The skipped tube, or null when a scan matched several and none was
  /// picked.
  final (TissueItemKind, int)? key;
}

/// Picks one tube when a code matches several. Null skips the scan.
typedef TissuePartPicker =
    Future<TissueItemRecord?> Function(List<TissueItemRecord> records);

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

  /// Names a parasite without a parasite ID in [labelFor].
  String parasiteLabel = 'Parasite';
  final Map<TissueCell, List<TissueItemRecord>> _occupied = {};
  final List<TissueCheckEntry> _entries = [];
  final List<TissueSkipEntry> _skipped = [];
  TissueCell? _next;
  Future<void> _pending = Future.value();

  TissueCheckSettings get settings => _settings;

  /// The layout boxes are filled and read with, standard labels unless
  /// custom labels are on.
  TissueBoxLayout get layout => _settings.effectiveLayout;

  /// Filled cells and the tubes in them, whether placed by this tool or
  /// typed in the part and parasite forms. Usually one tube per cell;
  /// several when hand-typed locations collide.
  Map<TissueCell, List<TissueItemRecord>> get occupied =>
      Map.unmodifiable(_occupied);

  /// The tubes in [cell] of the current box.
  List<TissueItemRecord> itemsAt(TissueCell cell) =>
      List.unmodifiable(_occupied[cell] ?? const <TissueItemRecord>[]);

  /// This session's checked tubes, newest first.
  List<TissueCheckEntry> get entries => List.unmodifiable(_entries.reversed);

  /// Tubes skipped in this session and not placed since, newest first.
  List<TissueSkipEntry> get skipped => List.unmodifiable(_skipped.reversed);

  TissueCell? get next => _next;
  int get filledCount => _occupied.length;
  bool get isFull => _next == null;

  String? get nextLocation => _next == null
      ? null
      : formatTissueLocation(
          _settings.boxLabel,
          _settings.boxNumber,
          layout.cellLabel(_next!),
          format: layout.labelFormat,
        );

  /// Reads which cells of the current box are already filled.
  Future<void> load() => _serial(_loadBox);

  /// Applies [settings] at once, then saves them and refills the box view
  /// when the box or its layout changed.
  Future<void> updateSettings(TissueCheckSettings settings) {
    final previous = _settings;
    _settings = settings;
    final reload =
        settings.effectiveLayout != previous.effectiveLayout ||
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

  /// Moves back one box. Box 1 has none before it.
  Future<void> previousBox() async {
    if (_settings.boxNumber <= 1) return;
    return updateSettings(
      _settings.copyWith(boxNumber: _settings.boxNumber - 1),
    );
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
  Future<TissueScanOutcome> place(TissueItemRecord record) {
    return _serial(() async {
      await service.loadFieldIds();
      return _place(record, labelFor(record));
    });
  }

  /// Notes [record] as skipped on the work list.
  void skip(TissueItemRecord record) {
    _addSkip(TissueSkipEntry(label: labelFor(record), key: record.key));
  }

  /// Unplaced tubes that match the type and treatment filters, in field ID
  /// order.
  Future<List<TissueItemRecord>> workList() {
    return service.workList(
      partTypes: _settings.partTypes,
      preservations: _settings.preservations,
      includeParasites: _settings.includeParasites,
      parasiteCategories: _settings.parasiteCategories,
    );
  }

  /// The codes the current identify mode can match, for suggestions.
  Future<List<String>> scanCodes() {
    return service.scanCodes(
      identifyBy: _settings.identifyBy,
      includeParasites: _settings.includeParasites,
    );
  }

  /// How a tube is named in messages and the log: its tissue or parasite
  /// ID, or its field ID with part type, or Parasite, and treatment.
  String labelFor(TissueItemRecord record) {
    final code = record.code?.trim() ?? '';
    if (code.isNotEmpty) return code;
    return [
      service.fieldIdOf(record.specimen.uuid),
      (record.isParasite ? parasiteLabel : record.type) ?? '',
      record.treatment ?? '',
    ].map((e) => e.trim()).where((e) => e.isNotEmpty).join(' · ');
  }

  /// The specimen side of a tube: its field ID, its part type or Parasite,
  /// and its treatment.
  String detailFor(TissueItemRecord record) {
    return [
      service.fieldIdOf(record.specimen.uuid),
      (record.isParasite ? parasiteLabel : record.type) ?? '',
      record.treatment ?? '',
    ].map((e) => e.trim()).where((e) => e.isNotEmpty).join(' · ');
  }

  /// A label short enough for a box cell: the last four characters of the
  /// tissue or parasite ID, or else of the field ID. Parasites lead with P
  /// so they stand apart from parts in the grid.
  String shortLabelFor(TissueItemRecord record) {
    final code = record.code?.trim() ?? '';
    final base = code.isNotEmpty
        ? code
        : service.fieldIdOf(record.specimen.uuid);
    final length = record.isParasite ? 3 : 4;
    final tail = base.length <= length
        ? base
        : base.substring(base.length - length);
    final hasMarker = tail.toUpperCase().startsWith('P');
    return record.isParasite && !hasMarker ? 'P$tail' : tail;
  }

  /// The text the work list search looks through: the label, field ID,
  /// barcode, type, and treatment.
  String searchTextFor(TissueItemRecord record) {
    return [
      labelFor(record),
      service.fieldIdOf(record.specimen.uuid),
      record.barcode ?? '',
      (record.isParasite ? parasiteLabel : record.type) ?? '',
      record.treatment ?? '',
    ].join(' ');
  }

  /// Reverts the most recent check. Returns null when there is none.
  Future<TissueScanOutcome?> undoLast() {
    return _serial(() async {
      if (_entries.isEmpty) return null;
      final entry = _entries.removeLast();
      await service.revert(
        entry.kind,
        entry.itemId,
        field: entry.field,
        value: entry.previousValue,
        location: entry.previousLocation,
      );
      onWrite?.call();
      if (entry.boxNumber != _settings.boxNumber) {
        _settings = _settings.copyWith(boxNumber: entry.boxNumber);
        await saveSettings(_settings);
      }
      await _loadBox();
      _next = layout.contains(entry.cell) && !_occupied.containsKey(entry.cell)
          ? entry.cell
          : _next;
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
      partTypes: _settings.partTypes,
      preservations: _settings.preservations,
      includeParasites: _settings.includeParasites,
      parasiteCategories: _settings.parasiteCategories,
    );
    final TissueItemRecord? record;
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
      _addSkip(TissueSkipEntry(label: code));
      return TissueScanOutcome(TissueScanStatus.skipped, 'Skipped: $code');
    }
    return _place(record, code);
  }

  Future<TissueScanOutcome> _place(TissueItemRecord record, String code) async {
    final value = _settings.value.trim();
    if (value.isEmpty) {
      return TissueScanOutcome(
        TissueScanStatus.invalid,
        'Enter a value for ${_settings.field.label} first',
      );
    }
    final label = labelFor(record).isEmpty ? code : labelFor(record);
    if (_entries.any((e) => (e.kind, e.itemId) == record.key)) {
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
      record,
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
        kind: record.kind,
        itemId: record.id,
        field: _settings.field,
        value: value,
        boxNumber: _settings.boxNumber,
        cell: cell,
        location: location,
        previousValue: write.previousValue,
        previousLocation: write.previousLocation,
      ),
    );
    _skipped.removeWhere((e) => e.key == record.key || e.label == code);
    // Reads the box back, so the cell holds the tube as stored now.
    await _loadBox();
    _next = layout.firstFree(_occupied.keys.toSet(), from: cell);
    return TissueScanOutcome(
      TissueScanStatus.checked,
      '$label → $location · ${_settings.field.label} = $value',
    );
  }

  /// Keeps one skip per tube, moved to the newest position.
  void _addSkip(TissueSkipEntry entry) {
    _skipped
      ..removeWhere(
        (e) => entry.key != null ? e.key == entry.key : e.label == entry.label,
      )
      ..add(entry);
  }

  Future<void> _loadBox() async {
    _occupied.clear();
    final items = await service.itemsInBox(
      _settings.boxName,
      format: layout.labelFormat,
    );
    for (final item in items) {
      final cell = parseTissueLocation(
        layout,
        boxLabel: _settings.boxLabel,
        boxNumber: _settings.boxNumber,
        location: item.storageLocation ?? '',
      );
      if (cell != null) _occupied.putIfAbsent(cell, () => []).add(item);
    }
    _next = layout.firstFree(_occupied.keys.toSet());
  }

  Future<T> _serial<T>(Future<T> Function() operation) {
    final result = _pending.then((_) => operation());
    _pending = result.then<void>((_) {}, onError: (_) {});
    return result;
  }
}
