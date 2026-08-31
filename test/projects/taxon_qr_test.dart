import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/import/taxon_entry.dart';
import 'package:nahpu/services/import/taxon_qr_session.dart';
import 'package:nahpu/services/record_exchange/taxon_exchange_service.dart';

const _rankNames = {
  'class': ('taxonClass', 'Mammalia'),
  'order': ('taxonOrder', 'Rodentia'),
  'family': ('taxonFamily', 'Muridae'),
  'genus': ('genus', 'Rattus'),
  'species': ('specificEpithet', 'rattus'),
  'subspecies': ('subspecificEpithet', 'rattus'),
};

String _qr(Map<String, Object?> data) =>
    jsonEncode({'nahpu_taxon': 1, 'taxon': data});

void main() {
  for (final rank in _rankNames.entries) {
    test('decodes sparse ${rank.key} and infers its legacy rank', () {
      for (final legacy in [false, true]) {
        final data = TaxonExchangeService.decodeQr(
          _qr({
            if (!legacy) 'taxonRank': rank.key,
            rank.value.$1: rank.value.$2,
          }),
        );
        expect(data.taxonRank, rank.key);
        expect(data.kingdom, isNull);
        expect(data.phylum, isNull);
      }
    });
    test('round trips existing ${rank.key} registry QR payload', () {
      final taxon = TaxonomyData(
        id: 42,
        taxonRank: rank.key,
        kingdom: 'Animalia',
        phylum: 'Chordata',
        taxonClass: 'Mammalia',
        taxonOrder: 'Rodentia',
        taxonFamily: 'Muridae',
        genus: 'Rattus',
        specificEpithet: 'rattus',
        subspecificEpithet: 'alexandrinus',
        authors: '(Linnaeus, 1758)',
        commonName: 'Black Rat',
        citesStatus: 'II',
        redListCategory: 'LC',
        countryStatus: 'Protected',
      );
      final data = TaxonExchangeService.decodeQr(
        TaxonExchangeService.encodeQr(taxon),
      );
      expect(data.taxonRank, rank.key);
      expect(data.kingdom, taxon.kingdom);
      expect(data.phylum, taxon.phylum);
      expect(data.taxonClass, taxon.taxonClass);
      expect(data.taxonOrder, taxon.taxonOrder);
      expect(data.taxonFamily, taxon.taxonFamily);
      expect(data.genus, taxon.genus);
      expect(data.specificEpithet, taxon.specificEpithet);
      expect(data.subspecificEpithet, taxon.subspecificEpithet);
      expect(data.authors, taxon.authors);
      expect(data.commonName, taxon.commonName);
      expect(data.citesStatus, taxon.citesStatus);
      expect(data.redListCategory, taxon.redListCategory);
      expect(data.countryStatus, taxon.countryStatus);
    });
  }

  test('legacy inference uses deepest name, ignoring empty names', () {
    final data = TaxonExchangeService.decodeQr(
      _qr({
        'taxonRank': '',
        'taxonClass': 'Mammalia',
        'genus': 'Rattus',
        'specificEpithet': 'rattus',
        'subspecificEpithet': '  ',
      }),
    );
    expect(data.taxonRank, 'species');
  });

  test('rejects malformed, unrelated, unsupported, and nameless QR data', () {
    for (final payload in [
      '',
      'https://nahpu.app',
      '{',
      'null',
      '[]',
      '1',
      '{"nahpu_specimen":1}',
      '{"nahpu_taxon":"1","taxon":{}}',
      '{"nahpu_taxon":1.0,"taxon":{}}',
      '{"nahpu_taxon":2,"taxon":{}}',
      '{"nahpu_taxon":1}',
      '{"nahpu_taxon":1,"taxon":[]}',
      _qr({}),
      _qr({'commonName': 'Black rat'}),
      _qr({'taxonRank': 'kingdom', 'kingdom': 'Animalia'}),
      _qr({'taxonRank': 'species', 'genus': 'Rattus'}),
      _qr({'taxonRank': 'class', 'taxonClass': '  '}),
    ]) {
      expect(
        () => TaxonExchangeService.decodeQr(payload),
        throwsFormatException,
        reason: payload,
      );
    }
  });

  test('validates every carried field type', () {
    for (final field in [
      'taxonRank',
      'kingdom',
      'phylum',
      'taxonClass',
      'taxonOrder',
      'taxonFamily',
      'genus',
      'specificEpithet',
      'subspecificEpithet',
      'authors',
      'commonName',
      'citesStatus',
      'redListCategory',
      'countryStatus',
    ]) {
      for (final invalid in [1, true, [], {}]) {
        expect(
          () => TaxonExchangeService.decodeQr(
            _qr({'taxonRank': 'genus', 'genus': 'Rattus', field: invalid}),
          ),
          throwsFormatException,
          reason: field,
        );
      }
    }
  });

  test(
    'batch serializes review, suppresses frames, and deduplicates names',
    () async {
      final gate = Completer<void>();
      var calls = 0;
      final session = TaxonQrSession(
        mode: TaxonQrImportMode.multiple,
        reviewData: (entries) async {
          calls++;
          if (calls == 1) await gate.future;
          return _review(entries);
        },
      );
      final rat = _qr({'taxonRank': 'genus', 'genus': 'Rattus'});
      final first = session.scan(rat);
      expect(await session.scan(rat), isNull);
      final second = session.scan(_qr({'genus': 'Bunomys'}));
      await Future<void>.delayed(Duration.zero);
      expect(calls, 1);
      gate.complete();
      expect((await first)!.accepted, isTrue);
      expect((await second)!.accepted, isTrue);
      expect((await session.scan(rat))!.message, startsWith('Duplicate:'));
      expect(await session.scan(rat), isNull);
      final duplicate = await session.scan(
        _qr({'genus': ' RATTUS ', 'authors': 'Other'}),
      );
      expect(duplicate!.message, startsWith('Duplicate:'));
      expect(duplicate.accepted, isFalse);
      expect(session.readyCount, 2);
      expect(calls, 2);
    },
  );

  test('single mode accepts only the first valid taxon', () async {
    final session = TaxonQrSession(
      mode: TaxonQrImportMode.single,
      reviewData: _review,
    );
    expect((await session.scan('unrelated'))!.isError, isTrue);
    final results = await Future.wait([
      session.scan(_qr({'genus': 'Rattus'})),
      session.scan(_qr({'genus': 'Bunomys'})),
    ]);
    expect(results.first!.accepted, isTrue);
    expect(results.last, isNull);
    expect(session.readyCount, 1);
  });

  test('registered taxa are queued for preview but never ready', () async {
    final session = TaxonQrSession(
      mode: TaxonQrImportMode.multiple,
      reviewData: (entries) async => TaxonImportReview(
        candidates: [
          TaxonImportCandidate(
            sourceRow: 1,
            data: entries.single,
            status: TaxonImportStatus.alreadyRegistered,
          ),
        ],
      ),
    );
    expect(
      (await session.scan(_qr({'genus': 'Rattus'})))!.message,
      'Already registered: Rattus',
    );
    expect(session.readyCount, 0);
    expect(session.review.candidates.single.isSelectable, isFalse);
  });

  test('closing a session discards in-flight and queued scans', () async {
    final gate = Completer<void>();
    final session = TaxonQrSession(
      mode: TaxonQrImportMode.multiple,
      reviewData: (entries) async {
        await gate.future;
        return _review(entries);
      },
    );
    final first = session.scan(_qr({'genus': 'Rattus'}));
    final second = session.scan(_qr({'genus': 'Bunomys'}));
    await Future<void>.delayed(Duration.zero);
    session.close();
    gate.complete();
    expect(await first, isNull);
    expect(await second, isNull);
    expect(session.review.candidates, isEmpty);
  });

  test('review failures can be retried without poisoning the queue', () async {
    var fail = true;
    final session = TaxonQrSession(
      mode: TaxonQrImportMode.multiple,
      reviewData: (entries) async {
        if (fail) throw StateError('database unavailable');
        return _review(entries);
      },
    );
    final payload = _qr({'genus': 'Rattus'});
    expect((await session.scan(payload))!.isError, isTrue);
    fail = false;
    expect((await session.scan(payload))!.accepted, isTrue);
  });
}

Future<TaxonImportReview> _review(List<TaxonEntryData> entries) async =>
    TaxonImportReview(
      candidates: [
        for (var i = 0; i < entries.length; i++)
          TaxonImportCandidate(
            sourceRow: i + 1,
            data: entries[i],
            status: TaxonImportStatus.ready,
          ),
      ],
    );
