import 'dart:io';
import 'package:nahpu/screens/shared/layout.dart';
import 'package:nahpu/services/types/controllers.dart';
import 'package:flutter/material.dart';
import 'package:nahpu/screens/shared/buttons.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_svg/svg.dart';
import 'package:share_plus/share_plus.dart';

class FileOperationPage extends StatelessWidget {
  const FileOperationPage({
    super.key,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    required this.children,
  });

  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
          child: ScrollableConstrainedLayout(
        child: Column(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          children: children,
        ),
      )),
    );
  }
}

class FileNameField extends StatelessWidget {
  const FileNameField(
      {super.key, required this.controller, required this.onChanged});

  final FileOpCtrModel controller;
  final Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller.fileNameCtr,
      decoration: InputDecoration(
          labelText: 'File name',
          hintText: 'my_file',
          suffix: controller.fileNameCtr.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(
                    Icons.clear_rounded,
                  ),
                  onPressed: () {
                    controller.fileNameCtr.clear();
                  },
                )),
      keyboardType: TextInputType.text,
      onChanged: onChanged,
    );
  }
}

class SaveSecondaryButton extends StatelessWidget {
  const SaveSecondaryButton({
    super.key,
    required this.hasSaved,
  });

  final bool hasSaved;
  @override
  Widget build(BuildContext context) {
    return SecondaryButton(
      text: hasSaved ? 'Exit' : 'Cancel',
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }
}

class ErrorText extends StatelessWidget {
  const ErrorText({super.key, required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Text('Something went wrong: $error');
  }
}

class PathNotFoundText extends StatelessWidget {
  const PathNotFoundText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('Select a directory');
  }
}

class SelectDirField extends StatelessWidget {
  const SelectDirField({
    super.key,
    required this.dirPath,
    required this.onPressed,
    required this.onCanceled,
  });

  final Directory? dirPath;
  final VoidCallback onPressed;
  final VoidCallback onCanceled;

  @override
  Widget build(BuildContext context) {
    // return Platform.isIOS || Platform.isAndroid
    //     ? const SizedBox.shrink()
    return Row(
      children: [
        dirPath != null
            ? const Icon(Icons.folder_open_outlined)
            : const SizedBox.shrink(),
        Expanded(
          child: Text(
            _getDirPath(),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        dirPath == null
            ? IconButton(
                icon: const Icon(Icons.folder_outlined),
                onPressed: onPressed,
              )
            : IconButton(
                onPressed: onCanceled, icon: const Icon(Icons.clear_rounded)),
      ],
    );
  }

  String _getDirPath() {
    if (dirPath == null) {
      return 'Select directory';
    } else {
      String lastPath = p.basename(dirPath!.path);
      return '.../$lastPath';
    }
  }
}

class SelectFileField extends StatelessWidget {
  const SelectFileField({
    super.key,
    required this.filePath,
    required this.onPressed,
    required this.onCleared,
    required this.isLoading,
    required this.width,
    required this.maxWidth,
    this.supportedFormat,
  });

  final XFile? filePath;
  final VoidCallback onPressed;
  final VoidCallback onCleared;
  final bool isLoading;
  final String? supportedFormat;
  final double width;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: Container(
        width: width,
        height: 160,
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary.withAlpha(40),
            width: 2,
          ),
          color: Theme.of(context).colorScheme.secondary.withAlpha(24),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: filePath == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ProgressButton(
                    icon: Icons.folder_open_outlined,
                    label: 'Select file',
                    isRunning: isLoading,
                    onPressed: onPressed,
                  ),
                  supportedFormat != null
                      ? const SizedBox(height: 8)
                      : const SizedBox.shrink(),
                  supportedFormat != null
                      ? Text(
                          'Supported formats:\n$supportedFormat',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        )
                      : const SizedBox.shrink(),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.file_present,
                    size: 56,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  Chip(
                    label: Text(
                      p.basename(filePath!.path),
                      overflow: TextOverflow.ellipsis,
                    ),
                    side: BorderSide(
                      color:
                          Theme.of(context).colorScheme.secondary.withAlpha(24),
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    onDeleted: onCleared,
                    deleteIcon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
      ),
    );
  }
}

class FileFormatIcon extends StatelessWidget {
  const FileFormatIcon({super.key, required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: SvgPicture.asset(
          path,
          height: 116,
          width: 116,
          colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.primary,
            BlendMode.srcIn,
          ),
        ));
  }
}
