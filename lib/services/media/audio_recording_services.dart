import 'dart:io';

import 'package:nahpu/services/common/io_services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class MicrophonePermissionException implements Exception {
  const MicrophonePermissionException();

  @override
  String toString() => 'Microphone access is required to record audio.';
}

class AudioRecordingServices {
  AudioRecordingServices({AudioRecorder? recorder})
    : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;
  String? _activePath;

  Stream<RecordState> get stateChanges => _recorder.onStateChanged();

  Future<String> start() async {
    if (!await _recorder.hasPermission()) {
      throw const MicrophonePermissionException();
    }

    final encoder = await _preferredEncoder();
    final extension = encoder == AudioEncoder.wav ? 'wav' : 'm4a';
    final tempDirectory = await getTemporaryDirectory();
    final recordingDirectory = Directory(
      '${tempDirectory.path}${Platform.pathSeparator}$nahpuTempDir',
    );
    await recordingDirectory.create(recursive: true);
    final output = await AppIOServices(
      dir: recordingDirectory,
      fileStem: 'audio-$dateTimeStamp',
      ext: extension,
    ).getSavePath();
    _activePath = output.path;
    await _recorder.start(
      RecordConfig(encoder: encoder, numChannels: 1),
      path: output.path,
    );
    return output.path;
  }

  Future<void> pause() => _recorder.pause();

  Future<void> resume() => _recorder.resume();

  Future<String?> stop() async {
    final path = await _recorder.stop();
    _activePath = path;
    return path;
  }

  Future<void> discard() async {
    try {
      await _recorder.cancel();
    } catch (_) {
      // A stopped or never-started recorder may have no active platform
      // session to cancel. The temporary file still needs to be removed.
    }
    final activePath = _activePath;
    _activePath = null;
    if (activePath == null) return;
    final file = File(activePath);
    if (await file.exists()) await file.delete();
  }

  void releaseFile() => _activePath = null;

  Future<AudioEncoder> _preferredEncoder() async {
    if (await _recorder.isEncoderSupported(AudioEncoder.aacLc)) {
      return AudioEncoder.aacLc;
    }
    if (await _recorder.isEncoderSupported(AudioEncoder.wav)) {
      return AudioEncoder.wav;
    }
    throw UnsupportedError(
      'This device does not support AAC or WAV audio recording.',
    );
  }

  Future<void> dispose() async {
    try {
      await _recorder.dispose();
    } catch (_) {
      // The platform recorder may already have been released by cancellation.
    }
  }
}
