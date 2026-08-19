import 'dart:async';
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/import/multimedia.dart';
import 'package:nahpu/screens/shared/media/media_details.dart';
import 'package:nahpu/services/types/file_format.dart';
import 'package:nahpu/services/types/import.dart';
import 'package:video_player/video_player.dart';

const double _metadataPanelWidth = 360;
const double _smallScreenBreakpoint = 600;
const List<double> _playbackSpeeds = [
  0.25,
  0.5,
  0.75,
  1.0,
  1.25,
  1.5,
  1.75,
  2.0,
];

/// Opens a pop-up viewer displaying the full media (image, video, or audio)
/// for the tapped thumbnail, with next/previous navigation and a metadata
/// panel.
Future<void> showMediaViewerDialog(
  BuildContext context, {
  required List<MediaData> mediaList,
  required int initialIndex,
}) {
  final isSmallScreen =
      MediaQuery.sizeOf(context).width < _smallScreenBreakpoint;
  if (isSmallScreen) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => MediaViewerDialog._bottomSheet(
        mediaList: mediaList,
        initialIndex: initialIndex,
      ),
    );
  }
  return showDialog(
    context: context,
    builder: (context) {
      return MediaViewerDialog(
        mediaList: mediaList,
        initialIndex: initialIndex,
      );
    },
  );
}

class MediaViewerDialog extends ConsumerStatefulWidget {
  const MediaViewerDialog({
    super.key,
    required this.mediaList,
    required this.initialIndex,
  }) : _useBottomSheet = false;

  const MediaViewerDialog._bottomSheet({
    required this.mediaList,
    required this.initialIndex,
  }) : _useBottomSheet = true;

  final List<MediaData> mediaList;
  final int initialIndex;
  final bool _useBottomSheet;

  @override
  MediaViewerDialogState createState() => MediaViewerDialogState();
}

class MediaViewerDialogState extends ConsumerState<MediaViewerDialog> {
  static const double _smallSheetInitialSize = 0.88;
  static const double _smallSheetMinSize = 0.55;
  static const double _smallSheetMaxSize = 1.0;

  late int _currentIndex;
  bool _showMetadata = true;
  bool _isFullscreen = false;
  int _loadToken = 0;
  bool _isLoading = true;
  File? _mediaFile;
  MediaKind _mediaKind = MediaKind.other;
  bool _canDisplay = false;
  VideoPlayerController? _videoController;
  double _volume = 1.0;
  double _lastNonZeroVolume = 1.0;
  double _playbackSpeed = 1.0;
  final FocusNode _focusNode = FocusNode();
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  MediaData get _currentMedia => widget.mediaList[_currentIndex];

  bool get _hasPrevious => _currentIndex > 0;

  bool get _hasNext => _currentIndex < widget.mediaList.length - 1;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.mediaList.length - 1);
    if (widget._useBottomSheet) {
      _sheetController.addListener(_onSheetExtentChanged);
    }
    _loadMedia();
  }

  @override
  void dispose() {
    _sheetController.dispose();
    _videoController?.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _goTo(_currentIndex - 1);
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _goTo(_currentIndex + 1);
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.escape && _isFullscreen) {
        _setFullscreen(false);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final viewer = widget._useBottomSheet
        ? _buildBottomSheet(context)
        : Dialog(
            insetPadding: _isFullscreen
                ? EdgeInsets.zero
                : const EdgeInsets.all(16),
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              width: screenSize.width,
              height: screenSize.height,
              child: _isFullscreen
                  ? _buildMediaArea(context)
                  : _buildWideViewer(context),
            ),
          );
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: viewer,
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: _smallSheetInitialSize,
      minChildSize: _smallSheetMinSize,
      maxChildSize: _smallSheetMaxSize,
      expand: false,
      builder: (context, _) {
        return Material(
          clipBehavior: Clip.antiAlias,
          color: Theme.of(context).colorScheme.surface,
          child: DefaultTabController(
            length: 2,
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  _buildTopBar(context, showMetadataToggle: false),
                  TabBar(
                    tabs: const [
                      Tab(icon: Icon(Icons.image_outlined), text: 'Media'),
                      Tab(icon: Icon(Icons.info_outline), text: 'Info'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildMediaArea(context),
                        _MediaMetadataPanel(media: _currentMedia),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWideViewer(BuildContext context) {
    return Column(
      children: [
        _buildTopBar(context),
        Expanded(
          child: LayoutBuilder(
            builder: (context, _) {
              if (!_showMetadata) {
                return _buildMediaArea(context);
              }
              return Row(
                children: [
                  Expanded(child: _buildMediaArea(context)),
                  SizedBox(
                    width: _metadataPanelWidth,
                    child: _MediaMetadataPanel(media: _currentMedia),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context, {bool showMetadataToggle = true}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _currentMedia.fileName ?? 'No media',
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (showMetadataToggle)
            IconButton(
              tooltip: _showMetadata ? 'Hide details' : 'Show details',
              icon: Icon(_showMetadata ? Icons.info : Icons.info_outline),
              onPressed: () {
                setState(() {
                  _showMetadata = !_showMetadata;
                });
              },
            ),
          if (!widget._useBottomSheet)
            IconButton(
              tooltip: 'Close',
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMediaArea(BuildContext context) {
    final controller = _videoController;
    final bool showPlaybackControls =
        !_isLoading &&
        _canDisplay &&
        controller != null &&
        (_mediaKind == MediaKind.video || _mediaKind == MediaKind.audio);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Expanded(child: _buildMediaOverlay(context)),
            if (showPlaybackControls)
              _PlaybackControls(
                controller: controller,
                volume: _volume,
                playbackSpeed: _playbackSpeed,
                isFullscreen: _isFullscreen,
                onToggle: _togglePlayback,
                onToggleMute: _toggleMute,
                onVolumeChanged: _setVolume,
                onSpeedChanged: _setPlaybackSpeed,
                onToggleFullscreen: _toggleFullscreen,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaOverlay(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(child: _buildMediaContent(context)),
        if (_hasPrevious)
          Positioned(
            left: 8,
            child: _NavigationButton(
              icon: Icons.chevron_left,
              tooltip: 'Previous',
              onPressed: () => _goTo(_currentIndex - 1),
            ),
          ),
        if (_hasNext)
          Positioned(
            right: 8,
            child: _NavigationButton(
              icon: Icons.chevron_right,
              tooltip: 'Next',
              onPressed: () => _goTo(_currentIndex + 1),
            ),
          ),
        Positioned(
          right: 12,
          bottom: 12,
          child: _MediaCounter(
            current: _currentIndex + 1,
            total: widget.mediaList.length,
          ),
        ),
      ],
    );
  }

  Widget _buildMediaContent(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_canDisplay) {
      return _MediaViewerFallback(kind: _mediaKind);
    }
    switch (_mediaKind) {
      case MediaKind.image:
        return InteractiveViewer(
          minScale: 0.8,
          maxScale: 10,
          child: Center(
            child: Image.file(
              _mediaFile!,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const _MediaViewerFallback(kind: MediaKind.image);
              },
            ),
          ),
        );
      case MediaKind.video:
      case MediaKind.audio:
        final controller = _videoController;
        if (controller == null) {
          return _MediaViewerFallback(kind: _mediaKind);
        }
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _togglePlayback,
            child: _mediaKind == MediaKind.video
                ? Center(
                    child: AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: VideoPlayer(controller),
                    ),
                  )
                : Center(
                    child: Icon(
                      Icons.audiotrack,
                      size: 120,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
          ),
        );
      case MediaKind.other:
        return _MediaViewerFallback(kind: _mediaKind);
    }
  }

  Future<void> _loadMedia() async {
    final token = ++_loadToken;
    final oldController = _videoController;
    setState(() {
      _isLoading = true;
      _canDisplay = false;
      _videoController = null;
    });
    await oldController?.dispose();

    final media = _currentMedia;
    final fileName = media.fileName ?? '';
    final kind = matchMediaKindFromPath(fileName);
    File? file;
    bool exists = false;
    try {
      final category = matchMediaCategoryString(media.category ?? '');
      file = await ImageServices(
        ref: ref,
        category: category,
      ).getMediaPath(fileName);
      exists = await file.exists();
    } catch (e) {
      exists = false;
    }

    VideoPlayerController? controller;
    bool canDisplay = exists && kind != MediaKind.other && fileName.isNotEmpty;
    if (canDisplay &&
        (kind == MediaKind.video || kind == MediaKind.audio) &&
        file != null) {
      controller = VideoPlayerController.file(file);
      try {
        await controller.initialize();
        // Carry the volume and playback speed chosen for a previous item
        // over to the newly loaded one.
        await controller.setVolume(_volume);
        await controller.setPlaybackSpeed(_playbackSpeed);
      } catch (e) {
        // Do not await: if initialization failed before the platform player
        // was created, dispose() never completes.
        unawaited(controller.dispose().catchError((_) {}));
        controller = null;
        canDisplay = false;
      }
    }

    if (!mounted || token != _loadToken) {
      await controller?.dispose();
      return;
    }
    final bool hasPlaybackControls =
        canDisplay &&
        controller != null &&
        (kind == MediaKind.video || kind == MediaKind.audio);
    setState(() {
      _isLoading = false;
      _mediaFile = file;
      _mediaKind = kind;
      _canDisplay = canDisplay;
      _videoController = controller;
      if (_isFullscreen && !hasPlaybackControls) {
        // Never trap the user in fullscreen with no visible exit button:
        // media without playback controls has no fullscreen toggle.
        _isFullscreen = false;
      }
    });
  }

  void _goTo(int index) {
    if (index < 0 || index >= widget.mediaList.length) {
      return;
    }
    setState(() {
      _currentIndex = index;
    });
    _loadMedia();
  }

  void _togglePlayback() {
    final controller = _videoController;
    if (controller == null) {
      return;
    }
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
  }

  void _setVolume(double volume) {
    setState(() {
      _volume = volume;
      if (volume > 0) {
        _lastNonZeroVolume = volume;
      }
    });
    _videoController?.setVolume(volume);
  }

  void _toggleMute() {
    _setVolume(_volume > 0 ? 0 : _lastNonZeroVolume);
  }

  void _setPlaybackSpeed(double speed) {
    setState(() {
      _playbackSpeed = speed;
    });
    _videoController?.setPlaybackSpeed(speed);
  }

  void _toggleFullscreen() {
    _setFullscreen(!_isFullscreen);
  }

  void _setFullscreen(bool value) {
    final nextValue = value;
    if (_isFullscreen != nextValue) {
      setState(() => _isFullscreen = nextValue);
    }
    if (!widget._useBottomSheet || !_sheetController.isAttached) return;
    _sheetController.animateTo(
      nextValue ? _smallSheetMaxSize : _smallSheetInitialSize,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  void _onSheetExtentChanged() {
    if (!mounted || !_sheetController.isAttached) return;
    final isFullscreen = _sheetController.size >= _smallSheetMaxSize - 0.01;
    if (isFullscreen != _isFullscreen) {
      setState(() => _isFullscreen = isFullscreen);
    }
  }
}

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: 32,
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(
          context,
        ).colorScheme.surface.withAlpha((0.7 * 255).toInt()),
        shape: const CircleBorder(),
      ),
    );
  }
}

class _MediaCounter extends StatelessWidget {
  const _MediaCounter({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surface.withAlpha((0.7 * 255).toInt()),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$current / $total',
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }
}

class _PlaybackControls extends StatelessWidget {
  const _PlaybackControls({
    required this.controller,
    required this.volume,
    required this.playbackSpeed,
    required this.isFullscreen,
    required this.onToggle,
    required this.onToggleMute,
    required this.onVolumeChanged,
    required this.onSpeedChanged,
    required this.onToggleFullscreen,
  });

  final VideoPlayerController controller;
  final double volume;
  final double playbackSpeed;
  final bool isFullscreen;
  final VoidCallback onToggle;
  final VoidCallback onToggleMute;
  final ValueChanged<double> onVolumeChanged;
  final ValueChanged<double> onSpeedChanged;
  final VoidCallback onToggleFullscreen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
      child: ValueListenableBuilder<VideoPlayerValue>(
        valueListenable: controller,
        builder: (context, value, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: value.isPlaying ? 'Pause' : 'Play',
                    icon: Icon(
                      value.isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                    onPressed: onToggle,
                  ),
                  Expanded(
                    child: VideoProgressIndicator(
                      controller,
                      allowScrubbing: true,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_formatDuration(value.position)} / '
                    '${_formatDuration(value.duration)}',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: volume > 0 ? 'Mute' : 'Unmute',
                    icon: Icon(volume > 0 ? Icons.volume_up : Icons.volume_off),
                    onPressed: onToggleMute,
                  ),
                  SizedBox(
                    width: 110,
                    child: Slider(
                      value: volume.clamp(0.0, 1.0),
                      onChanged: onVolumeChanged,
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<double>(
                    tooltip: 'Playback speed',
                    initialValue: playbackSpeed,
                    onSelected: onSpeedChanged,
                    itemBuilder: (context) {
                      return [
                        for (final speed in _playbackSpeeds)
                          PopupMenuItem(value: speed, child: Text('${speed}x')),
                      ];
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${playbackSpeed}x',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const Icon(Icons.arrow_drop_down, size: 18),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: isFullscreen ? 'Exit fullscreen' : 'Fullscreen',
                    icon: Icon(
                      isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                    ),
                    onPressed: onToggleFullscreen,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return '${duration.inHours}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}

class _MediaViewerFallback extends StatelessWidget {
  const _MediaViewerFallback({required this.kind});

  final MediaKind kind;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: 52,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 8),
          Text(
            'Cannot display this ${matchMediaKindLabel(kind).toLowerCase()}'
            ' file',
          ),
        ],
      ),
    );
  }
}

class _MediaMetadataPanel extends StatelessWidget {
  const _MediaMetadataPanel({required this.media});

  final MediaData media;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 8, 8),
      child: MediaDetailsView(media: media),
    );
  }
}
