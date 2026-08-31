import 'package:nahpu/services/import/taxon_entry.dart';
import 'package:nahpu/services/record_exchange/taxon_exchange_service.dart';

enum TaxonQrImportMode { single, multiple }

class TaxonQrScanResult {
  const TaxonQrScanResult({
    required this.message,
    this.isError = false,
    this.accepted = false,
  });

  final String message;
  final bool isError;
  final bool accepted;
}

/// Owns a single camera session. It never writes to the database.
class TaxonQrSession {
  TaxonQrSession({required this.mode, required this.reviewData});

  final TaxonQrImportMode mode;
  final Future<TaxonImportReview> Function(List<TaxonEntryData>) reviewData;
  final _entries = <TaxonEntryData>[];
  final _identities = <String>{};
  String? _lastPayload;
  final _pendingPayloads = <String>{};
  Future<void> _pending = Future.value();
  bool _closed = false;
  TaxonImportReview _review = const TaxonImportReview(candidates: []);

  TaxonImportReview get review => _review;
  int get readyCount => _review.selectableCandidates.length;

  Future<TaxonQrScanResult?> scan(String? rawValue) {
    final payload = rawValue?.trim() ?? '';
    if (_closed || _lastPayload == payload || !_pendingPayloads.add(payload)) {
      return Future.value();
    }
    _lastPayload = payload;
    final operation = _pending.then((_) => _scan(payload));
    _pending = operation.then((_) {
      _pendingPayloads.remove(payload);
    });
    return operation;
  }

  void close() => _closed = true;

  Future<TaxonQrScanResult?> _scan(String payload) async {
    if (_closed || (mode == TaxonQrImportMode.single && _entries.isNotEmpty)) {
      return null;
    }
    try {
      final entry = TaxonExchangeService.decodeQr(payload);
      final candidate = TaxonImportCandidate(
        sourceRow: _entries.length + 1,
        data: entry,
        status: TaxonImportStatus.ready,
      );
      if (_identities.contains(candidate.identityKey)) {
        return TaxonQrScanResult(
          message: 'Duplicate: ${candidate.displayName.trim()}',
        );
      }
      final reviewed = await reviewData([..._entries, entry]);
      if (_closed) return null;
      _entries.add(entry);
      _identities.add(candidate.identityKey);
      _review = reviewed;
      final alreadyRegistered =
          reviewed.candidates.last.status ==
          TaxonImportStatus.alreadyRegistered;
      return TaxonQrScanResult(
        message:
            '${alreadyRegistered ? 'Already registered' : 'Added'}: ${candidate.displayName.trim()}',
        accepted: true,
      );
    } on FormatException catch (error) {
      return TaxonQrScanResult(message: error.message, isError: true);
    } catch (_) {
      if (_lastPayload == payload) _lastPayload = null;
      // Transient review failures may be retried by scanning the code again.
      return const TaxonQrScanResult(
        message: 'Unable to review taxon. Try again.',
        isError: true,
      );
    }
  }
}
