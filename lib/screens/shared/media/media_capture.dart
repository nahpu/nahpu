import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:material_ui/material_ui.dart';
import 'package:nahpu/screens/shared/actions/buttons.dart';
import 'package:video_player/video_player.dart';

enum MediaCaptureMode { photo, video }

Future<String?> showMediaCapture(BuildContext context) {
  return Navigator.of(context).push<String>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => const MediaCaptureScreen(),
    ),
  );
}

class MediaCaptureScreen extends StatefulWidget {
  const MediaCaptureScreen({super.key});

  @override
  State<MediaCaptureScreen> createState() => _MediaCaptureScreenState();
}

class _MediaCaptureScreenState extends State<MediaCaptureScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  VideoPlayerController? _reviewController;
  List<CameraDescription> _cameras = const [];
  MediaCaptureMode _mode = MediaCaptureMode.photo;
  String? _capturedPath;
  String? _error;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;
  bool _isInitializing = true;
  bool _isCapturing = false;
  bool _isRecording = false;
  bool _accepted = false;
  int _cameraIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCameras();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed &&
        _capturedPath == null &&
        !_isRecording) {
      _initializeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _close();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(_capturedPath == null ? 'Take photos/videos' : 'Review'),
          leading: IconButton(
            tooltip: 'Close',
            onPressed: _close,
            icon: const Icon(Icons.close),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(child: _buildPreview()),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.errorContainer,
                    ),
                  ),
                ),
              _capturedPath == null
                  ? _CaptureControls(
                      mode: _mode,
                      isRecording: _isRecording,
                      isCapturing: _isCapturing,
                      recordingDuration: _recordingDuration,
                      canSwitchCamera: _cameras.length > 1,
                      onModeChanged: _setMode,
                      onCapture: _capture,
                      onSwitchCamera: _switchCamera,
                    )
                  : _ReviewControls(onRetake: _retake, onUse: _useMedia),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    if (_capturedPath != null) {
      if (_mode == MediaCaptureMode.photo) {
        return Center(
          child: Image.file(File(_capturedPath!), fit: BoxFit.contain),
        );
      }
      final reviewController = _reviewController;
      if (reviewController == null || !reviewController.value.isInitialized) {
        return Center(
          child: _error == null
              ? const CircularProgressIndicator()
              : const Icon(
                  Icons.video_file_outlined,
                  size: 72,
                  color: Colors.white,
                ),
        );
      }
      return Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: reviewController.value.aspectRatio,
              child: VideoPlayer(reviewController),
            ),
          ),
          IconButton.filledTonal(
            tooltip: reviewController.value.isPlaying ? 'Pause' : 'Play',
            iconSize: 40,
            onPressed: () async {
              reviewController.value.isPlaying
                  ? await reviewController.pause()
                  : await reviewController.play();
              if (mounted) setState(() {});
            },
            icon: Icon(
              reviewController.value.isPlaying ? Icons.pause : Icons.play_arrow,
            ),
          ),
        ],
      );
    }

    final controller = _controller;
    if (_isInitializing ||
        controller == null ||
        !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    // CameraPreview already applies the orientation-aware aspect ratio. A
    // second AspectRatio around it would use the raw sensor ratio and stretch
    // portrait previews on platforms that rotate the preview internally.
    return Center(child: CameraPreview(controller));
  }

  Future<void> _initializeCameras() async {
    setState(() {
      _isInitializing = true;
      _error = null;
    });
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw CameraException('no-camera', 'No camera is available.');
      }
      if (_cameraIndex >= _cameras.length) _cameraIndex = 0;
      await _initializeCamera();
    } on CameraException catch (error) {
      _setError(_cameraMessage(error));
    } catch (error) {
      _setError(error.toString());
    }
  }

  Future<void> _initializeCamera() async {
    if (_cameras.isEmpty || !mounted) return;
    setState(() => _isInitializing = true);
    await _disposeCamera();
    final controller = CameraController(
      _cameras[_cameraIndex],
      ResolutionPreset.high,
      enableAudio: true,
    );
    _controller = controller;
    try {
      await controller.initialize();
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _error = null;
        });
      }
    } on CameraException catch (error) {
      _setError(_cameraMessage(error));
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _isCapturing || _isRecording) return;
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    await _initializeCamera();
  }

  void _setMode(MediaCaptureMode mode) {
    if (_isCapturing || _isRecording || _capturedPath != null) return;
    setState(() => _mode = mode);
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _isCapturing) {
      return;
    }
    if (_mode == MediaCaptureMode.video) {
      await (_isRecording ? _stopVideo() : _startVideo());
      return;
    }

    setState(() {
      _isCapturing = true;
      _error = null;
    });
    try {
      final file = await controller.takePicture();
      if (!mounted) return;
      setState(() => _capturedPath = file.path);
    } on CameraException catch (error) {
      _setError(_cameraMessage(error));
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<void> _startVideo() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    setState(() {
      _isCapturing = true;
      _error = null;
      _recordingDuration = Duration.zero;
    });
    try {
      await controller.startVideoRecording();
      _recordingTimer?.cancel();
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() => _recordingDuration += const Duration(seconds: 1));
        }
      });
      if (mounted) setState(() => _isRecording = true);
    } on CameraException catch (error) {
      _setError(_cameraMessage(error));
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<void> _stopVideo() async {
    final controller = _controller;
    if (controller == null || !_isRecording) return;
    setState(() => _isCapturing = true);
    _recordingTimer?.cancel();
    try {
      final file = await controller.stopVideoRecording();
      if (!mounted) return;
      _capturedPath = file.path;
      _reviewController = VideoPlayerController.file(File(file.path));
      try {
        await _reviewController!.initialize();
      } catch (error) {
        _error = 'Playback preview is unavailable: $error';
        _reviewController?.dispose().ignore();
        _reviewController = null;
      }
      if (mounted) setState(() {});
    } on CameraException catch (error) {
      _setError(_cameraMessage(error));
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
          _isRecording = false;
        });
      }
    }
  }

  Future<void> _retake() async {
    await _reviewController?.dispose();
    _reviewController = null;
    final capturedPath = _capturedPath;
    _capturedPath = null;
    if (capturedPath != null) await _deleteTemporaryFile(capturedPath);
    if (mounted) setState(() {});
  }

  void _useMedia() {
    final capturedPath = _capturedPath;
    if (capturedPath == null) return;
    _accepted = true;
    Navigator.of(context).pop(capturedPath);
  }

  Future<void> _close() async {
    if (_isRecording) {
      try {
        final file = await _controller?.stopVideoRecording();
        if (file != null) await _deleteTemporaryFile(file.path);
      } catch (_) {
        // The controller can already be stopping as the route closes.
      }
    }
    if (!_accepted && _capturedPath != null) {
      await _deleteTemporaryFile(_capturedPath!);
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _disposeCamera() async {
    final controller = _controller;
    _controller = null;
    await controller?.dispose();
  }

  void _setError(String message) {
    if (!mounted) return;
    setState(() {
      _error = message;
      _isInitializing = false;
      _isCapturing = false;
      _isRecording = false;
    });
  }

  String _cameraMessage(CameraException error) {
    return switch (error.code) {
      'CameraAccessDenied' ||
      'CameraAccessDeniedWithoutPrompt' ||
      'CameraAccessRestricted' =>
        'Camera access is required to take photos and videos.',
      'AudioAccessDenied' ||
      'AudioAccessDeniedWithoutPrompt' ||
      'AudioAccessRestricted' =>
        'Microphone access is required to record video.',
      _ => error.description ?? 'Unable to use the camera.',
    };
  }

  Future<void> _deleteTemporaryFile(String path) async {
    final file = File(path);
    try {
      if (await file.exists()) await file.delete();
    } catch (_) {
      // Temporary cleanup should not prevent the capture route from closing.
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _recordingTimer?.cancel();
    _controller?.dispose();
    _reviewController?.dispose();
    if (!_accepted && _capturedPath != null) {
      File(_capturedPath!).delete().ignore();
    }
    super.dispose();
  }
}

class _CaptureControls extends StatelessWidget {
  const _CaptureControls({
    required this.mode,
    required this.isRecording,
    required this.isCapturing,
    required this.recordingDuration,
    required this.canSwitchCamera,
    required this.onModeChanged,
    required this.onCapture,
    required this.onSwitchCamera,
  });

  final MediaCaptureMode mode;
  final bool isRecording;
  final bool isCapturing;
  final Duration recordingDuration;
  final bool canSwitchCamera;
  final ValueChanged<MediaCaptureMode> onModeChanged;
  final VoidCallback onCapture;
  final VoidCallback onSwitchCamera;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<MediaCaptureMode>(
              segments: const [
                ButtonSegment(
                  value: MediaCaptureMode.photo,
                  icon: Icon(Icons.photo_camera_outlined),
                  label: Text('Photo'),
                ),
                ButtonSegment(
                  value: MediaCaptureMode.video,
                  icon: Icon(Icons.videocam_outlined),
                  label: Text('Video'),
                ),
              ],
              selected: {mode},
              onSelectionChanged: isRecording || isCapturing
                  ? null
                  : (selection) => onModeChanged(selection.first),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 72,
                  child: canSwitchCamera
                      ? IconButton(
                          tooltip: 'Switch camera',
                          color: Colors.white,
                          onPressed: isRecording || isCapturing
                              ? null
                              : onSwitchCamera,
                          icon: const Icon(Icons.cameraswitch_outlined),
                        )
                      : null,
                ),
                IconButton.filled(
                  tooltip: mode == MediaCaptureMode.photo
                      ? 'Take photo'
                      : isRecording
                      ? 'Stop recording'
                      : 'Record video',
                  iconSize: 40,
                  onPressed: isCapturing ? null : onCapture,
                  style: IconButton.styleFrom(
                    backgroundColor: isRecording ? Colors.red : Colors.white,
                    foregroundColor: isRecording ? Colors.white : Colors.black,
                  ),
                  icon: Icon(
                    mode == MediaCaptureMode.photo
                        ? Icons.camera_alt
                        : isRecording
                        ? Icons.stop
                        : Icons.fiber_manual_record,
                  ),
                ),
                SizedBox(
                  width: 72,
                  child: isRecording
                      ? Text(
                          _formatDuration(recordingDuration),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white),
                        )
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _ReviewControls extends StatelessWidget {
  const _ReviewControls({required this.onRetake, required this.onUse});

  final VoidCallback onRetake;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: onRetake,
              icon: const Icon(Icons.refresh),
              label: const Text('Retake'),
            ),
            const SizedBox(width: 8),
            PrimaryButton(onPressed: onUse, label: 'Use', icon: Icons.check),
          ],
        ),
      ),
    );
  }
}
