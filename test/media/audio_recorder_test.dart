import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahpu/screens/shared/media/audio_recorder.dart';
import 'package:nahpu/services/audio_recording_services.dart';
import 'package:record/record.dart';

void main() {
  testWidgets('audio recorder supports pause, resume, review, and discard', (
    tester,
  ) async {
    final directory = Directory.systemTemp.createTempSync('nahpu-audio-test');
    addTearDown(() {
      if (directory.existsSync()) directory.deleteSync(recursive: true);
    });
    final recordingPath = '${directory.path}/recording.m4a';
    final services = _FakeAudioRecordingServices(recordingPath);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AudioRecorderView(serviceFactory: () => services)),
      ),
    );

    await tester.tap(find.text('Record'));
    await tester.pump();
    expect(find.byTooltip('Pause'), findsOneWidget);
    expect(find.text('Stop'), findsOneWidget);

    await tester.tap(find.byTooltip('Pause'));
    await tester.pump();
    expect(find.byTooltip('Resume'), findsOneWidget);

    await tester.tap(find.byTooltip('Resume'));
    await tester.pump();
    expect(find.byTooltip('Pause'), findsOneWidget);

    await tester.tap(find.text('Stop'));
    await tester.pumpAndSettle();
    expect(find.text('Save'), findsOneWidget);
    expect(find.text('Discard'), findsOneWidget);

    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.text('Record'), findsOneWidget);
    expect(services.discardCount, 1);
  });
}

class _FakeAudioRecordingServices extends AudioRecordingServices {
  _FakeAudioRecordingServices(this.recordingPath);

  final String recordingPath;
  final _states = StreamController<RecordState>.broadcast();
  int discardCount = 0;

  @override
  Stream<RecordState> get stateChanges => _states.stream;

  @override
  Future<String> start() async {
    File(recordingPath).writeAsBytesSync([1, 2, 3]);
    _states.add(RecordState.record);
    return recordingPath;
  }

  @override
  Future<void> pause() async => _states.add(RecordState.pause);

  @override
  Future<void> resume() async => _states.add(RecordState.record);

  @override
  Future<String?> stop() async {
    _states.add(RecordState.stop);
    return recordingPath;
  }

  @override
  Future<void> discard() async {
    discardCount++;
    final file = File(recordingPath);
    if (file.existsSync()) file.deleteSync();
  }

  @override
  Future<void> dispose() async {
    await _states.close();
  }
}
