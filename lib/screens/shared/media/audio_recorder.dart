import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:nahpu/services/audio_recording_services.dart';
import 'package:record/record.dart';
import 'package:video_player/video_player.dart';

typedef AudioRecordingServiceFactory = AudioRecordingServices Function();

Future<String?> showAudioRecorder(
  BuildContext context, {
  AudioRecordingServiceFactory serviceFactory = AudioRecordingServices.new,
}) {
  final recorder = AudioRecorderView(serviceFactory: serviceFactory);
  if (MediaQuery.sizeOf(context).width < 600) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: recorder,
        ),
      ),
    );
  }
  return showDialog<String>(
    context: context,
    builder: (context) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: recorder,
      ),
    ),
  );
}

class AudioRecorderView extends StatefulWidget {
  const AudioRecorderView({
    super.key,
    this.serviceFactory = AudioRecordingServices.new,
  });

  final AudioRecordingServiceFactory serviceFactory;

  @override
  State<AudioRecorderView> createState() => _AudioRecorderViewState();
}

class _AudioRecorderViewState extends State<AudioRecorderView> {
  late final AudioRecordingServices _recordingServices;
  StreamSubscription<RecordState>? _stateSubscription;
  VideoPlayerController? _reviewController;
  Timer? _timer;
  RecordState _recordState = RecordState.stop;
  Duration _duration = Duration.zero;
  String? _recordingPath;
  String? _error;
  bool _isBusy = false;
  bool _accepted = false;

  bool get _isReviewing => _recordingPath != null;

  @override
  void initState() {
    super.initState();
    _recordingServices = widget.serviceFactory();
    _stateSubscription = _recordingServices.stateChanges.listen((state) {
      if (!mounted) return;
      setState(() => _recordState = state);
      if (state == RecordState.record) {
        _startTimer();
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _close();
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Record audio',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: _close,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Icon(
              _isReviewing ? Icons.audio_file_outlined : Icons.mic_none,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              _formatDuration(_duration),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 24),
            if (_isReviewing)
              _buildReviewControls()
            else
              _buildRecordControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordControls() {
    final isRecording = _recordState == RecordState.record;
    final isPaused = _recordState == RecordState.pause;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isRecording || isPaused)
          IconButton.filledTonal(
            tooltip: isPaused ? 'Resume' : 'Pause',
            onPressed: _isBusy
                ? null
                : isPaused
                ? _resume
                : _pause,
            icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
          ),
        if (isRecording || isPaused) const SizedBox(width: 16),
        PrimaryButton(
          onPressed: _isBusy
              ? null
              : isRecording || isPaused
              ? _stop
              : _start,
          label: isRecording || isPaused ? 'Stop' : 'Record',
          icon: isRecording || isPaused ? Icons.stop : Icons.mic,
        ),
      ],
    );
  }

  Widget _buildReviewControls() {
    final reviewController = _reviewController;
    final canPlay = reviewController?.value.isInitialized ?? false;
    final isPlaying = reviewController?.value.isPlaying ?? false;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          tooltip: isPlaying ? 'Pause playback' : 'Play recording',
          onPressed: canPlay ? _togglePlayback : null,
          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: _isBusy ? null : _discard,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Discard'),
            ),
            const SizedBox(width: 8),
            PrimaryButton(
              onPressed: _isBusy ? null : _save,
              label: 'Save',
              icon: Icons.check,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _start() async {
    setState(() {
      _isBusy = true;
      _error = null;
      _duration = Duration.zero;
    });
    try {
      await _recordingServices.start();
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _pause() async {
    try {
      await _recordingServices.pause();
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _resume() async {
    try {
      await _recordingServices.resume();
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _stop() async {
    setState(() => _isBusy = true);
    try {
      final path = await _recordingServices.stop();
      if (path == null) throw StateError('The audio recording was not saved.');
      _recordingPath = path;
      _reviewController = VideoPlayerController.file(File(path));
      try {
        await _reviewController!.initialize();
      } catch (error) {
        _error = 'Playback preview is unavailable: $error';
        _reviewController?.dispose().ignore();
        _reviewController = null;
      }
      if (mounted) setState(() {});
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _togglePlayback() async {
    final controller = _reviewController;
    if (controller == null) return;
    controller.value.isPlaying
        ? await controller.pause()
        : await controller.play();
    if (mounted) setState(() {});
  }

  Future<void> _discard() async {
    setState(() => _isBusy = true);
    try {
      await _reviewController?.dispose();
    } catch (_) {
      // Playback may be unavailable even though the recording can be saved.
    }
    _reviewController = null;
    try {
      await _recordingServices.discard();
    } catch (error) {
      _showError(error);
    }
    if (mounted) {
      setState(() {
        _recordingPath = null;
        _duration = Duration.zero;
        _error = null;
        _recordState = RecordState.stop;
        _isBusy = false;
      });
    }
  }

  void _save() {
    final recordingPath = _recordingPath;
    if (recordingPath == null) return;
    _accepted = true;
    _recordingServices.releaseFile();
    Navigator.of(context).pop(recordingPath);
  }

  Future<void> _close() async {
    try {
      await _recordingServices.discard();
    } catch (_) {
      // Closing the recorder should remain possible after a platform error.
    }
    if (mounted) Navigator.of(context).pop();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _duration += const Duration(seconds: 1));
    });
  }

  void _showError(Object error) {
    if (!mounted) return;
    setState(() => _error = error.toString());
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stateSubscription?.cancel();
    _reviewController?.dispose();
    if (!_accepted) _recordingServices.discard();
    _recordingServices.dispose();
    super.dispose();
  }
}
