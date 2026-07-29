import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:nahpu/services/providers/settings.dart';
import 'package:nahpu/services/providers/validation.dart';
import 'package:nahpu/screens/shared/common/common.dart';
import 'package:nahpu/services/import/multimedia.dart';
import 'package:nahpu/services/personnel_services.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:nahpu/services/types/import.dart';
import 'package:nahpu/services/platform_services.dart';
import 'package:path/path.dart';

const int avatarSize = 160;

class PersonnelAvatar extends ConsumerStatefulWidget {
  const PersonnelAvatar({
    super.key,
    required this.ctr,
  });

  final PersonnelFormCtrModel ctr;

  @override
  PersonnelAvatarState createState() => PersonnelAvatarState();
}

class PersonnelAvatarState extends ConsumerState<PersonnelAvatar> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: avatarSize.toDouble(),
      height: avatarSize.toDouble(),
      child: Stack(
        children: [
          widget.ctr.photoPathCtr.text.isEmpty
              ? ref.watch(catalogFmtNotifierProvider).when(
                    data: (data) {
                      final defaultAvatar =
                          PersonnelImageService().getDefaultAvatar(data);
                      widget.ctr.photoPathCtr.text = defaultAvatar;
                      return Positioned.fill(
                          child: DefaultAvatar(
                        filePath: defaultAvatar,
                      ));
                    },
                    loading: () => const Center(
                      child: CommonProgressIndicator(),
                    ),
                    error: (error, stack) => const Center(
                      child: Text('Error'),
                    ),
                  )
              : Positioned.fill(
                  child: AvatarViewer(
                    avatarCtr: widget.ctr.photoPathCtr,
                  ),
                ),
          Positioned(
            bottom: 0,
            right: 8,
            child: systemPlatform == PlatformType.mobile
                ? ImageSpeedDials(
                    onSelectPhoto: _selectPhoto,
                    onTakePhoto: _takePhoto,
                  )
                : ImageButton(
                    onPressed: _selectPhoto,
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectPhoto() async {
    final image = await ImageServices(
      ref: ref,
      category: MediaCategory.personnel,
    ).pickImageSingle();
    if (image.isNotEmpty) {
      _validateEditing();
      setState(() {
        widget.ctr.photoPathCtr.text = basename(image);
      });
    }
  }

  Future<void> _takePhoto() async {
    final image = await ImageServices(
      ref: ref,
      category: MediaCategory.personnel,
    ).accessCamera();
    if (image != null) {
      _validateEditing();
      setState(() {
        widget.ctr.photoPathCtr.text = basename(image);
      });
    }
  }

  void _validateEditing() {
    ref.read(personnelFormValidatorProvider.notifier).validateAll(widget.ctr);
  }
}

class AvatarViewer extends ConsumerStatefulWidget {
  const AvatarViewer({
    super.key,
    required this.avatarCtr,
  });

  final TextEditingController avatarCtr;
  // final int imageSize;

  @override
  AvatarViewerState createState() => AvatarViewerState();
}

class AvatarViewerState extends ConsumerState<AvatarViewer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.avatarCtr.text.startsWith(avatarPath)
        ? DefaultAvatar(filePath: widget.avatarCtr.text)
        : FutureBuilder(
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  foregroundImage: FileImage(snapshot.data as File),
                );
              } else {
                return const Center(
                  child: Text('Image not found'),
                );
              }
            },
            future: _getPersonnelMediaPath());
  }

  Future<File> _getPersonnelMediaPath() async {
    File path = await ImageServices(
      ref: ref,
      category: MediaCategory.personnel,
    ).getPersonnelMediaPath(widget.avatarCtr.text);
    return path;
  }
}

class DefaultAvatar extends StatelessWidget {
  const DefaultAvatar({super.key, required this.filePath});

  final String filePath;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        foregroundImage: AssetImage(filePath));
  }
}

class ImageButton extends StatelessWidget {
  const ImageButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(
            Icons.add_a_photo_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: onPressed,
        ));
  }
}

class ImageSpeedDials extends StatelessWidget {
  const ImageSpeedDials({
    super.key,
    required this.onSelectPhoto,
    required this.onTakePhoto,
  });

  final VoidCallback onSelectPhoto;
  final VoidCallback onTakePhoto;

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Icons.add_a_photo_outlined,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      foregroundColor: Theme.of(context).colorScheme.primary,
      direction: SpeedDialDirection.down,
      children: _getSpeedDial(context),
    );
  }

  List<SpeedDialChild> _getSpeedDial(BuildContext context) {
    if (systemPlatform == PlatformType.desktop) {
      return [
        _selectPhotoDial(context),
      ];
    }
    return [
      _takePhotoDial(context),
      _selectPhotoDial(context),
    ];
  }

  SpeedDialChild _takePhotoDial(BuildContext context) {
    return SpeedDialChild(
      child: Icon(Icons.camera_alt_outlined,
          color: Theme.of(context).colorScheme.onSecondary),
      backgroundColor: Theme.of(context).colorScheme.secondary,
      label: 'Take Photo',
      onTap: onTakePhoto,
    );
  }

  SpeedDialChild _selectPhotoDial(BuildContext context) {
    return SpeedDialChild(
      child: Icon(Icons.photo_library_outlined,
          color: Theme.of(context).colorScheme.onSecondary),
      backgroundColor: Theme.of(context).colorScheme.secondary,
      label: 'Select Photo',
      onTap: onSelectPhoto,
    );
  }
}
